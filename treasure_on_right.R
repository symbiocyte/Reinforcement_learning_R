cat('---o-T')
print('---o-')
for(i in 1:10){
  x<-sample(1:5,1)
  s1<-c(rep('-',5),'T')
  s1[x]<-'o'
  s2<-paste0(s1,collapse = '')
  cat('\r',s2);flush.console()
  Sys.sleep(1)
}

N_STATES = 8   # the length of the 1 dimensional world
ACTIONS = c('left', 'right')    # available actions
EPSILON = 0.9   # greedy police
ALPHA = 0.1     # learning rate
GAMMA = 0.9    # discount factor
MAX_EPISODES = 13   # maximum episodes
FRESH_TIME = 0.3    # fresh time for one move

#def build_q_table(n_states, actions):
#  table = pd.DataFrame(
#    np.zeros((n_states, len(actions))),     # q_table initial values
#    columns=actions,    # actions's name
#  )
## print(table)    # show table
#return table

build_q_table<-function(n_states, actions){
  m1<-matrix(data=0,nrow=n_states,ncol = length(actions))
  table1<-data.frame(m1)
  colnames(table1)<-actions
  rownames(table1)<-1:n_states
  return(table1)
}

#q_table<-build_q_table(N_STATES,ACTIONS)

#def choose_action(state, q_table):
  # This is how to choose an action
#  state_actions = q_table.iloc[state, :]
#if (np.random.uniform() > EPSILON) or ((state_actions == 0).all()):  # act non-greedy or state-action have no value
#  action_name = np.random.choice(ACTIONS)
#else:   # act greedy
#  action_name = state_actions.idxmax()    # replace argmax to idxmax as argmax means a different function in newer version of pandas
#return action_name

choose_action<-function(state, q_table){
  # This is how to choose an action
  
  x1<-runif(1, min = 0, max = 1)
  if(x1>EPSILON | sum(q_table[state,])==0){
    action_name <- sample(ACTIONS,1)   ## non greedy, random
  }else{
    x2<-which.max(q_table[state,])
    action_name <- ACTIONS[x2]    # greedy
  }
  return(action_name)
}

#choose_action(2,q_table)

#def get_env_feedback(S, A):
#  # This is how agent will interact with the environment
#  if A == 'right':    # move right
#  if S == N_STATES - 2:   # terminate
#  S_ = 'terminal'
#R = 1
#else:
#  S_ = S + 1
#R = 0
#else:   # move left
#  R = 0
#if S == 0:
#  S_ = S  # reach the wall
#else:
#  S_ = S - 1
#return S_, R


get_env_feedback <- function(S, A){
  if(A=='right'){
    if(S==N_STATES){
      S_ = 'terminal'
      R = 1
    }else{
      S_ = S + 1
      R = 0
    }
  }else{
    #move left
    R = 0
    if(S==1){
      S_ = S  # reach the wall
    }else{
      S_ = S - 1
    }
  }
  return(c(S_,R))
}

xx<-get_env_feedback(8,'right')
as.numeric(xx[2])
#def update_env(S, episode, step_counter):
#  # This is how environment be updated
#  env_list = ['-']*(N_STATES-1) + ['T']   # '---------T' our environment
#if S == 'terminal':
#  interaction = 'Episode %s: total_steps = %s' % (episode+1, step_counter)
#print('\r{}'.format(interaction), end='')
#time.sleep(2)
#print('\r                                ', end='')
#else:
#  env_list[S] = 'o'
#interaction = ''.join(env_list)
#print('\r{}'.format(interaction), end='')
#time.sleep(FRESH_TIME)
#

update_env <- function(S, episode, step_counter){
  env_list <- c(rep('-',N_STATES),'T')
  if(S=='terminal'){
    interaction <- c('Episode=',episode, ' total_steps= ',step_counter)
    interaction <- paste0(interaction,collapse = '')
    cat('\r',interaction)
    Sys.sleep(2)
    flush.console()
  }else{
    env_list[S] <- 'o'
    interaction <- paste0(env_list,collapse = '')
    cat('\r',interaction)
    Sys.sleep(FRESH_TIME)
    flush.console()
  }
}

#def rl():
#  # main part of RL loop
#  q_table = build_q_table(N_STATES, ACTIONS)
#for episode in range(MAX_EPISODES):
#  step_counter = 0
#S = 0
#is_terminated = False
#update_env(S, episode, step_counter)
#while not is_terminated:
  
#  A = choose_action(S, q_table)
#S_, R = get_env_feedback(S, A)  # take action & get next state and reward
#q_predict = q_table.loc[S, A]
#if S_ != 'terminal':
#  q_target = R + GAMMA * q_table.iloc[S_, :].max()   # next state is not terminal
#else:
#  q_target = R     # next state is terminal
#is_terminated = True    # terminate this episode

#q_table.loc[S, A] += ALPHA * (q_target - q_predict)  # update
#S = S_  # move to next state

#update_env(S, episode, step_counter+1)
#step_counter += 1
#return q_table

rl <- function(){
  q_table <- build_q_table(N_STATES, ACTIONS)
  for(episode in 1:MAX_EPISODES){
    step_counter <- 0
    S <- 1
    is_terminated <- F
    update_env(S, episode, step_counter)
    while(!is_terminated){
      A <- choose_action(S, q_table)
      S_R <- get_env_feedback(S, A)  # take action & get next state and reward  # vector of length 2 holds S' and R
      q_predict <- q_table[S, A]
      if(S_R[1] != 'terminal'){
        q_target <- S_R[2] + GAMMA * max(q_table[S_R[1],])
      }else{
        q_target <- as.numeric(S_R[2])  #R
        is_terminated <- T
      }
      q_table[S, A] <-  q_table[S, A] + ALPHA * (q_target - q_predict)  # update
      S <- S_R[1]  # move to next state
      update_env(S, episode, step_counter)
      step_counter <- step_counter + 1
    }
  }
  return(q_table)  
  
}

q_table <- rl()
