# Minesweeper
It's an implementation of the classical Minesweeper game based on the idee that the game has to be solvable without a guess.

The time to generate a solvable game increases exponentially with the size of the game and the percentage of mines on the field. I.e. the probability of finding a solution drops rapidly to almost zero if the mines or the game size goes up.   

I solved the problem by limiting the generation time. This means that I can't always generate a solvable game.

An other interresting fact is that a game containing an 8 is never solvable without guessing.   
I've seen generated games with 6 and 7 adjacent mines, but never one with 8 mines. Nevertheless, I intercepted this case. Consequently, you will never see an 8 in a solvable game.

## Motivation
The motivation to write the game stems from the fact that I've always wondered if it's possible to write a solvable minesweeper game and how to do something like that. The triggering moment was that DevNull ran ads in his game, which I don't appreciate at all. So I decided to write my own version of it.

## The Code
The code is copyright of ©Max Werner 2024.  
You can use the code for anything you want, as long as you don't use it along with ads, tracking, or analytics.

The code is too sparsely commented, even for myself. I'm sorry about that, but it is what it is.

### Supported Devices
The code runs on Android devices (phones & tablets). It should work on Apple devices too.
Web and desktop apps are not supported. It should be possible to run the code on this devices too but you have to rewrite the code in [mines_field.dart](./lib/pages/mines_page/components/mines_field.dart) at least.

## Project structure

The **model**-package contains the core logic of the game. It should be fairly independent from the GUI part.

The **pages**-package contains all the Flutter code for the GUI (the views).

The **provider**-package contains the glue between the model and the views.

### Model package
[mines_game.dart](./lib/model/mines_game.dart) contains the game state and logic for playing the game. The game state is a little bit too complicated. It holds the game state (running, win, gameOver) as well as some state used for the drawing (startingUp, unInitialized, calculating).   
All in all, it is too nitty gritty to be used directliy, so I abstacted it away with providers.

[mines_definitions.dart](./lib/model/mines_definitions.dart) contains some commonly used  data types.

[mines_logic.dart](./lib/model/mines_logic.dart) contains all code related to the game field.

[solver.dart](./lib/model/solver.dart) contains the code to generate a new (solvable) game.

### Pages package
The **pages**-package contains the Flutter code for the info, settings and mines page.

The code in the **mines**-package is a little bit messy as always in Flutter, especialy because I had some issues with the startup sequence und the readyness of the **SettingsProvider** class at startup.   
Using a **CustomMultiChildLayout** for the layout and a **CustomPainter** for the drawing doesen't ease the pain.  
Your millage in understanding the code will vary.

### Provider package
I use the [Provider](https://pub.dev/packages/provider) package for the view state handling. It may not be fancy, but it does the job.  

[GameProvider](./lib/provider/game_provider.dart) abstracts away the **MinesGame** class and serves as a kind of controller and view state provider.  
The other providers do what there names imply.

