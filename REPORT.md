# MP Report

## Student information

- Name: 
- AID: 

## Self-Evaluation Checklist

Tick the boxes (i.e., fill them with 'X's) that apply to your submission:

- [X] The app builds without error
- [X] I tested the app in at least one of the following platforms (check all
      that apply):
  - [ ] iOS simulator / MacOS
  - [X] Android emulator
- [X] Users can register and log in to the server via the app
- [X] Session management works correctly; i.e., the user stays logged in after
      closing and reopening the app, and token expiration necessitates re-login
- [X] The game list displays required information accurately (for both active
      and completed games), and can be manually refreshed
- [X] A game can be started correctly (by placing ships, and sending an
      appropriate request to the server)
- [X] The game board is responsive to changes in screen size
- [X] Games can be started with human and all supported AI opponents
- [X] Gameplay works correctly (including ship placement, attacking, and game
      completion)

## Summary and Reflection

I tried to keep the code organized by making a different dart file for each page. I also created model classes and implemented the REST api. The application works as it should. I implement the three AI types and are able to play with someone else. There is only two small errors that I was unable to fix. The first one is when you want to select to shoot an area that already has one of your ships. It is possible your opponent has their ship in that area, however, the game will not allow you to take the shot. Another error I found was that for the winning player, it gives a notification that they lost. However, when you check the game history, it will show that the winning player won.

Implementing the game board logic was quite enjoyable. What I found most difficult was trying to implement all the features like playing with an AI, login feature, and playing with other people online.
