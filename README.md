# Battleship Bot

This is a script that makes calls to http://battleship-smackdown.club/ and plays battleship! It takes in a game id as a parameter. 

<h2>Strategy</h2>
It searches the board randomly in a checkerboard pattern. 
If it's hit any ship, it will prioritize squares adjacent to the hit spaces. 
If there are are multiple hit spaces next to each other, it will prioritize searching in the same direction. For example, if there were 2 hit spaces next to each other horizontally, then it would search only the spaces directly to the right and left of the hit spaces.
