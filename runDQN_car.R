# run DQN
target_model<-load_model_hdf5('target_model_100.hdf5')
target_model<-load_model_hdf5('target_model_300.hdf5')
target_model<-load_model_hdf5('target_model_400.hdf5')

target_model<-load_model_hdf5('target_model_10000.hdf5')
model<-load_model_hdf5('model_10000.hdf5')
episode_count <- 10
max_steps <- 500
reward <- 0
done <- FALSE
for (i in 1:episode_count) {
  cur_state <- env_reset(client, instance_id)
  cur_state <- unlist(cur_state)
  for (i in 1:max_steps) {
    epsilon <- 0 # no random action
    action <- act(cur_state,model=target_model,action_space = action_space,epsilon)  #action needs to be 0,1 or 2
    results <- env_step(client, instance_id, action, render = TRUE)
    cat('\r','Action: ',action)
    cat('; Reward: ',results[["reward"]],'; done: ',results[["done"]],'; Step: ',i,'   ')
    #Sys.sleep(0.1)
    if (results[["done"]]) break
    cur_state <- unlist(results[['observation']])  ##new state
    
    predict(target_model,t(cur_state))
  }
  Sys.sleep(0.5)
}
