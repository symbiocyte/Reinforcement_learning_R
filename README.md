# Deep Reinforcement Learning with R
Contains examples for (deep) reinforcement learning using R, Keras (TF) and OpenAI-gym
The idea here is to transfer python code to R in order to run deep reinforcment learning algorithms directly. For theoretical background please refer to dedicated publications, e.g.<br>
Mnih <i>et al.</i> Playing Atari with Deep Reinforcement Learning (2013)<br>
Youtube: RL Course by David Silver<br>
Sutton & Barto,  Reinforcement Learning: An Introduction 2nd ed. (free online)<br>
...<br>

<b>Treasure on the right</b><br>
The first files <i>treasure_on_the_right.R</i> and <i>treasure_on_the_right1.1.R</i> are based on python code submitted by: 周莫烦<br>
His github is found at https://github.com/MorvanZhou/Reinforcement-learning-with-tensorflow

<i>treasure_on_the_right.R</i> contains also commented-out original python code.<br>
<i>treasure_on_the_right1.1.R</i> is a cleaned up version.<br>
The idea is simply that the agent o needs to find the target T. in a 1 dimensional world:<br>
o------T<br>
The agent starts on the left, can only move left or right and is only rewarded if it reaches the target T.<br>

<b>Q_RL_maze1.0.R</b><br>
In this script a maze problem is tackled, the agent starts in the upper left corner of a 4x4 maze which has 2 black holes and a treasure in the middle. The agent has to learn to walk around the holes to get to the treasure (see file Maze1.png). <br>
Note that here the Q-table is created on the fly, meaning that only when a new state (position in the maze) is experienced the Q values are appended to the table. <br>




