### Q-learning , maze

STATE=1  #top left corner (x=1,y=4), starting point
actions <- c('up', 'down', 'left', 'right')
# create a list
q_table <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(q_table)<-c('state',actions)
self<-list(actions=actions,learning_rate=0.01, reward_decay=0.9, e_greedy=0.9,q_table=q_table) ## empty data frame included
self$q_table

resamp <- function(x,...){if(length(x)==1) x else sample(x,...)}   #needed for weird behavior of sampling vectors of length 1
resamp(10,1)

require(stats); require(grDevices)

maze0<-function(){
  try({dev.off()})  ##clears plots
  
  #Draw a maze, red cyrcle gets updated
  symbols(2,2,squares = 0.8,inches = FALSE,bg='black',xlim = c(0.5,4.5),ylim = c(0.5,4.5),xlab = '',ylab = '')
  symbols(3,3,squares = 0.8,inches = FALSE,bg='black',add = T)
  symbols(3,2,squares = 0.8,inches = FALSE,bg='yellow',add = T)
  abline(v=c(0.5,1.5,2.5,3.5,4.5))
  abline(h=c(0.5,1.5,2.5,3.5,4.5))
  text(rep(1:4,4),c(rep(4,4),rep(3,4),rep(2,4),rep(1,4)), labels = 1:16 ,pos = 3, cex = 1, col = "blue")
}

maze1<-function(x,y){
  #maze0()
  #df_coo<-data.frame(x=rep(1:4,4),y=c(rep(4,4),rep(3,4),rep(2,4),rep(1,4)) )
    symbols(x,y,circles = 0.4,inches = FALSE, bg='red',add = T)
  Sys.sleep(0.2)
}

maze2<-function(x,y){
  # clears old symbol
  symbols(x,y,circles = 0.4,inches = FALSE, fg='white',bg='white',add = T)
}

maze3<-function(){
  Sys.sleep(0.1)
  symbols(3,2,circles = 0.4,inches = FALSE, fg='yellow',bg='yellow',add = T)
  symbols(2,2,circles = 0.4,inches = FALSE, fg='black',bg='black',add = T)
  symbols(3,3,circles = 0.4,inches = FALSE, fg='black',bg='black',add = T)
}

check_state_exists <- function(self,state){
  #check if this state is already in q_table and enters zeros
  #print(state)
  if(! state %in% self$q_table$state){
    #state does not jet exist in q_table
    y2<-rep(0,length(self$actions)+1)
    names(y2) <- c('state',self$actions)
    self$q_table<-rbind(self$q_table,t(y2))  # rbind really is a bitch in R
    self$q_table$state[nrow(self$q_table)] <- state
    
  }
  return(self)
}


choose_action<- function(self,observation){
  # action selection
  x1<-runif(1, min = 0, max = 1)
  #print(x1)
  if(x1<self$e_greedy){
    # choose best action
    state_action <- self$q_table[self$q_table$stat==observation,-1]  # -1: only action columns used
    
    action1<-which(state_action == max(state_action))
    
    action<- resamp(action1,1,replace = T)  #1:'up', 2:'down', 3:'left', 4:'right'
    #cat('Greedy: '); cat(action)
  }else{
    # choose random action
    action<- sample(1:4,1,replace = T)
  }
  #cat(action)
  #cat('\n')
  #Sys.sleep(0.5)
  return(action)
}


learn <- function(self, s, a, r, s_){
  
  s1<-which(self$q_table$state==s)  # gives the row of the state 
  q_predict <- self$q_table[s1,(a+1)]  # again q_table has states as first column
    if(s_ != 'terminal'){
      self<-check_state_exists(self,s_)
      s__<-which(self$q_table$state==s_)  # gives the row of the state 
      q_target <- r + self$reward_decay * max(self$q_table[s__, -1 ])  # next state is not terminal
  }else{
    q_target <- r  # next state is terminal
  }
  self$q_table[s1,(a+1)] <- self$q_table[s1,(a+1)] + self$learning_rate * (q_target - q_predict)
  #print(self$q_table[s1,(a+1)])
  return(self)
}

learn_SARSA <- function(self, s, a, r, s_, a_){
  # a_ the next state is also given
  s1<-which(self$q_table$state==s)  # gives the row of the state 
  q_predict <- self$q_table[s1,(a+1)]  # again q_table has states as first column
  if(s_ != 'terminal'){
    self<-check_state_exists(self,s_)
    s__<-which(self$q_table$state==s_)  # gives the row of the state 
    
    q_target <- r + self$reward_decay * self$q_table[s__, (a_ +1) ]  # next state is not terminal
  }else{
    q_target <- r  # next state is terminal
  }
  self$q_table[s1,(a+1)] <- self$q_table[s1,(a+1)] + self$learning_rate * (q_target - q_predict)
  #print(self$q_table[s1,(a+1)])
  return(self)
}

########################################################
##################################################
#1:'up', 2:'down', 3:'left', 4:'right'
step1<-function(observation, action){
  s<- observation
  
  move<-T
  x<-df_coo$x[s]
  y<-df_coo$y[s]
  if(action==1 && y==4){ move<-F } #up
  if(action==2 && y==1){ move<-F } #down
  if(action==3 && x==1){ move<-F } #left
  if(action==4 && x==4){ move<-F } #right
  if(move==T){
    maze2(x,y)
    if(action==1){y<-y+1}
    if(action==2){y<-y-1}
    if(action==3){x<-x-1}
    if(action==4){x<-x+1}
    maze1(x,y)  #paint maze
  }
  
  s_ <- which(df_coo$x==x & df_coo$y==y)  # new state
  # reward function
  if(s_==11){
    reward = 1
    done = T
    s_ = 'terminal'
    maze3()
  }else if(s_==7 || s_==10){
    reward = -1
    done = T
    s_ = 'terminal'
    maze3()
  }else{
    reward = 0
    done = F
  }
  return(list(s_=s_,reward=reward,done=done))  
}


df_coo<-data.frame(x=rep(1:4,4),y=c(rep(4,4),rep(3,4),rep(2,4),rep(1,4)) )  # translates observation into x,y

update <- function(){
  maze0()
  Sys.sleep(0.2)
  for(episode in 1:50){
    # initial observation
    observation = 1
    self<-check_state_exists(self,observation)  #SARSA
    action<-choose_action(self, observation)  #for SARSA, initial action
    done<-F
    maze1(1,4)
    Sys.sleep(0.5)
    while(done==F){
      
      # RL choose action based on observation
      self<-check_state_exists(self,observation)
      #self$q_table
      #action<-choose_action(self, observation)   # for Q-table
      ob_r_d<-step1(observation,action) # observation_, reward, done
      self<-check_state_exists(self, ob_r_d$s_)
      action_<-choose_action(self, ob_r_d$s_)  #for SARSA
     ## The order when is done what is important
      # RL take action and get next observation and reward
      #ob_r_d<-step1(observation,action) # observation_, reward, done
      ## new action
      #self<-learn(self,observation, action, ob_r_d$reward, ob_r_d$s_ )
      self<-learn_SARSA(self,observation, action, ob_r_d$reward, ob_r_d$s_, action_ )
      action <- action_   #SARSA
      observation <- ob_r_d$s_
      done<-ob_r_d$done  #break loop
      Sys.sleep(0.2)
    }
   print(self$q_table) 
    
  }
  return(self) 
}

self<-update()
