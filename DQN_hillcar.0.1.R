####################################################################################################################

#first start server on command line
#  cd gym-http-api
#  python gym_http_server.py
# R
library(gym)
library(keras)
####   create the environment, important for shapes of the data
remote_base <- "http://127.0.0.1:5000"
client <- create_GymClient(remote_base)
# env_id <- "CartPole-v0"
env_id <- "MountainCar-v0"
# env_id <- "Breakout-ram-v0"
instance_id <- env_create(client, env_id)

### thats it the sapes can be obtained:
action_space_info <- env_action_space_info(client, instance_id)
print(action_space_info)
observation_space_info<-env_observation_space_info(client, instance_id)
print(observation_space_info)
## create input and output shapes for models
shape<-unlist(env_observation_space_info(client, instance_id)[['shape']])  #e.g. the shape is 2  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
action_space <- env_action_space_info(client, instance_id)[['n']]

## make 3 memory matrices: memory.action.reward.done (memory.ard), memory.state0, memory.state1
memory.ard <- matrix(ncol =3, nrow=0)  #columns action.reward.done
memory.state0 <- matrix(ncol =shape, nrow=0)  #columns depend on environment, s
memory.state1 <- matrix(ncol =shape, nrow=0)  #columns depend on environment,  future state s'

##learning parameters
gamma <- 0.99
epsilon_min <- 0.005
epsilon_decay <- 0.995
learning_rate <- 0.001
tau <- 0.125
(0.8-0.005)/50000

#
##  now the models are created
###  first continously updated model
create_model<-function(){
  model <- keras_model_sequential() %>%
    layer_dense(units = 24, activation = 'relu',input_shape = c(shape)) %>%  ##input shape depends on environment,  env.observation_space.shape
    layer_dense(units = 48, activation = 'relu') %>%
    layer_dense(units = 24, activation = 'relu') %>%
    layer_dense(units = action_space, activation='linear')   ##output dependes on environment,  env.action_space.n
  
  model %>% compile(
    optimizer=optimizer_adam(lr=learning_rate),
    loss='mean_squared_error'
  )
  summary(model)
  return(model)
}
create_target_model<-function(){
  model <- keras_model_sequential() %>%
    layer_dense(units = 24, activation = 'relu',input_shape = c(shape),trainable=F) %>%  ##input shape depends on environment,  env.observation_space.shape
    layer_dense(units = 48, activation = 'relu',trainable=F) %>%
    layer_dense(units = 24, activation = 'relu',trainable=F) %>%
    layer_dense(units = action_space, activation='linear',trainable=F)   ##output dependes on environment,  env.action_space.n
  
  model %>% compile(
    optimizer=optimizer_adam(lr=learning_rate),
    loss='mean_squared_error'
  )
  summary(model)
  return(model)
}
create_target_model()
# calculate decaying epsilon
epsilon_dec <- function(epsilon){
  epsilon<-epsilon*epsilon_decay   #reduces epsilon over time (chance of random action decreases over time)
  epsilon<-max(c(epsilon,epsilon_min))  #smalles epsilon is epsilon_min
  return(epsilon)
}

act <- function(state,model,action_space,epsilon){
  if(runif(1)<epsilon){
    return(sample(action_space,1)-1)  #take random action,   action space 0-2  --> -1  !!!
  }else{
    p1<-predict(model,t(state))
    action <- which(max(p1)==p1)-1  #take prediction from model  (which gives 1,2 or 3  --> 0,1,2)
    return(action)  
  }
}

# make a memory matrix  ,  state needs to be a vector!!
remember<- function(memory, state, action, reward, new_state, done){
  memory$memory.ard <- rbind(memory$memory.ard,c(action, reward, done))
  memory$memory.state0 <- rbind(memory$memory.state0, state)
  memory$memory.state1 <- rbind(memory$memory.state1, new_state)
  if(nrow(memory$memory.ard)>2000){
    memory$memory.ard<-memory$memory.ard[-1,]
    memory$memory.state0 <-memory$memory.state0[-1,]
    memory$memory.state1 <-memory$memory.state1[-1,]
  }   #remove oldest memories
  return(memory)
  #return(list(memory.ard=memory.ard,memory.state0=memory.state0,memory.state1=memory.state1))
}


replay<- function(memory,model,target_model,action_space,gamma,mini_batch){  #memory is a list
  #mini_batch <- 64
  curr_size <- nrow(memory$memory.ard)  #current size of replay memory
  sel<-sample(curr_size,mini_batch)
  memory_sample_state0<- memory$memory.state0[sel,]  ##subset of memory
  memory_sample_state1<- memory$memory.state1[sel,]  ##subset of memory
  memory_sample_ard<- memory$memory.ard[sel,]
  target_action<-matrix(ncol = action_space,nrow = batch_size)
  for(i in 1:nrow(memory_sample_state0)){
    #i<-1
    target_action[i,] <- predict(target_model,t(memory_sample_state0[i,]))  ##does it predict reward or action???  --> for each action a value
    #           [,1]       [,2]       [,3]
    #[1,] -0.1259372 0.02047156 0.06870358
    
    act1 <- memory_sample_ard[i,1]+1  #position in target matrix for update
    done<-memory_sample_ard[i,3]  #done is in the last column
    
    if(done==1){
      
      target_action[i,act1] <- memory_sample_ard[i,2] #reward ## reward goes only into the successful action column
    }else{
      Q_future <- max(predict(target_model,t(memory_sample_state1[i,])))#Q_future is now a   #Q_future = max(self.target_model.predict(new_state)[0])
      target_action[i,act1] <- memory_sample_ard[i,2] + Q_future * gamma #target[0][action] = reward + Q_future * self.gamma
    }
    #self.model.fit(state, target, epochs=1, verbose=0)
  }
  model %>% fit(memory_sample_state0,target_action,epochs=1,batch_size=32, verbose=0)
  return(model)
}


target_train <- function(model,target_model,tau){
  weights <- get_weights(model)
  target_weights <- get_weights(target_model)
  L1<-lapply(weights,FUN = '*',tau)
  L2<-lapply(target_weights,FUN='*',(1 - tau))
  target_weights <-mapply('+',L1,L2)
  #target_weights <- weights * tau + target_weights * (1 - tau)  ## target weights are updated
  target_model<-set_weights(target_model,target_weights)
  return(target_model)
}

target_train_simple <- function(model,target_model){
  weights <- get_weights(model)
  target_model<-set_weights(target_model,weights)
  return(target_model)
}

main <- function(){
  model <- create_model()  ###  first continously updated model
  target_model <-create_model()  #and target model, same shape
  memory<-list(memory.ard=memory.ard,memory.state0=memory.state0,memory.state1=memory.state1)  # store it into memory list, all empty
  epsilon <- 0.99  # exploring parameter, decays over time
  trials  <- 500
  trial_len <- 300
  mini_batch <- 64 #replay memory batch
  train_start <- 1000
  updateTargetNetwork <- 50
  count_trials <-1
  #st<-1
  for(trial in 1:trials){
    cur_state <- env_reset(client, instance_id)
    cur_state <- unlist(cur_state)
    
    for(st in 1:trial_len){
      epsilon <- epsilon_dec(epsilon)
      action <- act(cur_state,model=model,action_space = action_space,epsilon)  #here is the problem!!!  action needs to be 0,1 or 2
      
      ns.r.d <- env_step(client, instance_id, action, render = F)  #new_state, reward, done #list
      new_state<- unlist(ns.r.d[[1]])
      memory <- remember(memory=memory, state=cur_state, action=action, reward=ns.r.d[[2]], new_state=new_state, done=ns.r.d[[3]])
      ## store in memory
      
      curr_size <- nrow(memory$memory.ard)  #current size of replay memory
      if(curr_size >= train_start ){
        model<-replay(memory,model,target_model,action_space,gamma,batch_size)  # internally iterates default (prediction) model
      }
      
      cur_state <- new_state
      if(ns.r.d[[3]]){break}
      
    }
    target_model<-target_train_simple(model,target_model) # iterates target model
    
    if(count_trials==updateTargetNetwork){
      #target_model<-target_train(model,target_model,tau) # iterates target model
      
      updateTargetNetwork<-updateTargetNetwork + 50
      #save Target model
      file_out<-paste(c('target_model_',count_trials,'.hdf5'),collapse = '')
      save_model_hdf5(target_model,file_out)
      # save also model
      #file_out<-paste(c('model_',count_trials,'.hdf5'),collapse = '')
      #save_model_hdf5(model,file_out)
      
      ### also save the memory table
      #mem_df<-suppressWarnings(data.frame(memory$memory.ard,memory$memory.state0,memory$memory.state1))
      #file_out2<-paste(c('mem_table_',count_trials,'.txt'),collapse = '')
      #write.table(mem_df,file_out2,sep='\t',row.names = F,col.names = F,quote = F)
    }
    flush.console()
    cat('\r','Trails: ',count_trials)
    cat(';  Reward: ',reward)
    count_trials<-count_trials+1
  }
  
}

main()
