Copyright &copy; 2024, Snag Delivery, Inc. All Rights Reserved
CONFIDENTIAL
Please do not distribute without prior authorization from Snag Delivery, Inc.


# Goblin Challenge - Game Algorithm Coding Assignment

## Game Backstory
In a cursed land full of dangerous traps and hidden treasures, Snaggy, the Goblin Chieftain, must gather precious resources—gold, diamonds, and chests—to save the Goblin village from a looming catastrophe. With traps set by ancient enemies scattered across the land, Snaggy needs your help to navigate the dangers, collect the treasures, and return safely to the village.

## Goal
The objective of the Goblin Challenge is to develop an algorithm that controls Snaggy, the Goblin Chieftain, in this grid-based world. Snaggy must explore the map, gather resources (such as gold, diamonds, and chests), avoid traps, and return the collected items to the village. Your goal is to create an efficient algorithm that helps Snaggy complete in as few moves as possible, without getting stuck in any of the dangerous traps.

## Rules
1. **Algorithm Logic**: Your algorithm will control Snaggy's movements based on the current tile and surrounding tiles. You are expected to implement a decision-making process that determines how Snaggy should move.
2. **Auto-Move**: Snaggy should automatically decide on each move based on the surroundings and whether to collect or drop resources.
3. **Traps and Rivers**: Snaggy must avoid traps and cannot cross rivers unless a bridge is available.
4. **Resources**: Snaggy can only carry 3 resources at a time and must return to the village to deposit them.
5. **Ending Conditions**: The game ends when all resources are collected or when Snaggy hits a trap. A run can also timeout if Snaggy is unable to move efficiently (this is considered being "stuck").
6. **Evaluation**: Your algorithm will be evaluated based on the number of moves it takes to complete the objectives, whether it gets stuck, and how efficiently it avoids traps and collects resources.

## Additional Instructions and Tips

- **Git History**: Please initialize the project with Git and maintain a full history of your commits. When submitting the project, include **all** files, including the `.git` directory, to show your full development history.
  
- **Use of LLMs**: We understand that AI tools are becoming a part of developers' toolkits. We do not consider the use of these tools as cheating. In fact, we encourage developers to use tools that can improve their productivity. If you choose to use such tools in your project, please include the chat transcript or conversation history as part of your submission. This can demonstrate your effective use of these tools in solving the problem.
  
- **Algorithm Behavior**: Your Snaggy algorithm should be able to handle randomness well since the game world is initialized with different seeds during each simulation. Design your algorithm to be adaptive and handle different layouts and challenges effectively.
  
- **Timeouts**: If Snaggy fails to complete the objectives within 100,000 moves, the run will be considered a failure. Design your algorithm to minimize the chances of getting timed-out. 

## Submission
Once completed, submit the project with the following:
1. **Project Files**: Ensure all code files are included.
2. **Git Repository**: Include the full `.git` directory so we can view your commit history.
3. **LLM Transcript (if applicable)**: If you used any AI tools in any part of your process, include a transcript of your conversations with these tools.

Good luck with the Goblin Challenge, and happy coding!
