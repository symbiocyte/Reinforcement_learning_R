# Deep Reinforcement Learning with R
Contains examples for (deep) reinforcement learning using R, Keras (TF) and OpenAI-gym
The idea here is to transfer python code to R in order to run deep reinforcment learning algorithms directly. For theoretical background please refer to dedicated publications, e.g.<br>
Mnih <i>et al.</i> Playing Atari with Deep Reinforcement Learning (2013)<br>
Youtube: RL Course by David Silver<br>
Sutton & Barto,  Reinforcement Learning: An Introduction 2nd ed. (free online)<br>
...<br>

<b>Treasure on the right</b><br>
The first file <i>treasure_on_the_right.R</i> and <i>treasure_on_the_right1.1.R</i> are based on python code submitted by: 周莫烦<br>
His github is found at https://github.com/MorvanZhou/Reinforcement-learning-with-tensorflow

<i>treasure_on_the_right.R</i> contains also commented-out original python code.<br>
The idea is simply that the agent o needs to find the target T. in a 1 dimensional world:<br>
o------T<br>
The agent starts on the left, can only move left or right and is only rewarded if it reaches the target T.


