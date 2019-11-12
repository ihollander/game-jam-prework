# DragonRuby Tutorial: Creating an Endless Runner

The game we're making is an endless runner, similar to Chrome's offline minigame: http://www.trex-game.skipser.com/. We'll have a player, some obstacles, and the ability to have the player jump over the obstacles. It'll be super cool.

## 00. Project Setup

Create a main directory for your game called `runner` inside the dragonruby directory. Inside the `runner` directory, create a directory called `app` and within that directory make a file called `main.rb`. Inside `main.rb`, write a method `tick`: 

```ruby
def tick args
  ...
end
```

DragonRuby will call this method every 'tick' of the game loop (https://gamedev.stackexchange.com/questions/651/how-should-i-write-a-main-game-loop). It will be called with an arguments hash that provides high-level details on the application state.

For example, the following code will create a new label on the screen and outupt the current `tick_count`:

```ruby
def tick args
  args.outputs.labels << [640, 380, args.game.tick_count, 0, 1]
end
```

You should have a directory structure that looks like: `~/dragonruby-macos/runner/app/main.rb`. To run the example enter the following (you should be in the main DragonRuby directory to run the DragonRuby executable): 

```bash
$ ./dragonruby runner
```

The DragonRuby game window will run and display the current tick count in the middle of the screen. Congrats!

Now that we've got the project set up, we'll work on separating out our game logic from the `tick` method to give our project some structure. Create a new class in the `main.rb` file:

```ruby
class Runner
  attr_accessor :game, :grid, :outputs

  # this will run on each tick
  def tick
    outputs.labels << [grid.right / 2, grid.top / 2, game.tick_count, 0, 1]
  end
end
```

Create a new instance of our newly created Runner class and pass it the arguments from our game's `tick` method. The `main.rb` file should now look like this:

```ruby
class Runner
  attr_accessor :game, :grid, :outputs

  # this will run on each tick
  def tick
    outputs.labels << [grid.right / 2, grid.top / 2, game.tick_count, 0, 1]
  end
end

# create our game instance
$runner = Runner.new

# main DragonRuby game loop
def tick args
  # pass info from DragonRuby tick to game instance
  $runner.game    = args.game
  $runner.grid    = args.grid
  $runner.outputs = args.outputs

  # invoke tick on the game
  $runner.tick
end
```

## 01. Platforms

Now we'll work on drawing out our platforms and creating the game screen. In `game.rb`, create a method called `render` and invoke it from the `tick` method:

```ruby
class Runner
...
  def tick
    # Redraw the game graphics
    render
  end

  def render
    # draw a black background
    outputs.solids << grid.rect # grid.rect == [grid.left, grid.top, grid.bottom, grid.right]
    # draw the floor
    outputs.solids << [grid.left, grid.bottom, grid.right, 60, 255, 0, 0, 255]
  end
```

Your game should now look something like this:
![01](./runner/assets/01.png?raw=true "Floor")

Now we'll add some obstacles to our game state. We'll have some default values to set our initial game state: a counter to check when we need to add a new obstacle, and an array to keep track of all the obstacles on the screen. Each tick of the game, we'll recalculate the state for these obstacles:

```ruby
  def tick
    set_defaults
    update_state # each tick, update the game state
    render
  end

  def set_defaults
    game.state.obstacles ||= []
    game.state.obstacle_countdown ||= 100
  end

  ### calculate new state on each tick
  def update_state
    # decrement countdown
    game.state.obstacle_countdown -= 1

    # move the obstacles left 8 pixels each frame
    game.state.obstacles.each { |w| w.rect[0] -= 8 }
    
    # remove the obstacles if they leave the screen
    game.state.obstacles.reject! { |w| w.rect[0] < -w.rect[2] }

    # generate a new obstacle each 100 ticks
    if game.state.obstacle_countdown == 0
      # reset the countdown randomly
      new_countdown = rand(200) + 40
      game.state.obstacle_countdown = new_countdown
      # create a new game entity for each obstacle
      obstacle = game.new_entity(:obstacle, {
        rect: [
          grid.right, # x
          grid.bottom + 60, # y
          40, # w
          80, # h
          255, 0, 0, 255 # rbga
        ]
      }) 
      
      # add it to our game state
      game.state.obstacles << obstacle
    end

  end
```

After creating the obstacles in our game state, we need to render them:

```ruby
def render
    ...
    # draw the obstacles
    game.state.obstacles.each do |obstacle| 
      outputs.solids << obstacle.rect
    end
  end
```

Now our game has some obstacles:
![02](./runner/assets/02.png?raw=true "Obstacles")

## 02. Player
Now we can create player! Add a position to our game state to give our player starting coordinates:

```ruby
  def set_defaults
    ...
    # player
    game.state.player ||= game.new_entity(:player, {
      rect: [
        grid.left + 60, # x
        grid.bottom + 60, # y
        60, # w
        60, # h
        0, 0, 255, 255 # rbga
      ],
      dy: 0, # this will be used to calculate player movement on the y axis
      jumping: false
    })
  end
```

And update the render method to draw the player:

```ruby
def render
  ... 
  # draw the player
  outputs.solids << game.state.player.rect
end
```

With our player added, the game should look like:
![02](./runner/assets/03.png?raw=true "Player")

In order to make the player jump, we'll need to get access to the inputs argument from the main DragonRuby `tick` method. Update our `attr_accessors` to include inputs and pass them in from the `tick` method:

```ruby
class Runner
  attr_accessor :game, :grid, :outputs, :inputs # added inputs

  ...
end

def tick args
  $runner.game    = args.game
  $runner.grid    = args.grid
  $runner.outputs = args.outputs
  $runner.inputs  = args.inputs # pass input from tick

  $runner.tick
end
```

Each tick, we'll process the input values to check for any changes, and update our game state accordingly. Add a new method `process_inputs` to the `Runner` class:

```ruby
def tick
  set_defaults
  process_inputs
  update_state
  render
end

def process_inputs
  if inputs.keyboard.key_down.space && !game.state.player.jumping
    game.state.player.jumping = true
    game.state.player.dy = 15
  end
end
```

Now we'll need to update the player's position if they're jumping and update the `dy` value to simulate jumping physics:

```ruby
def update_state
  ...
  # handle jumps
  if game.state.player.jumping
    # update y coordinate
    game.state.player.rect[1] += game.state.player.dy
    # update the dy value
    game.state.player.dy -= 0.9 # gravity!
    # hit the floor?
    if game.state.player.rect[1] <= grid.bottom + 60
      game.state.player.dy = 0
      game.state.player.jumping = false
      game.state.player.rect[1] = grid.bottom + 60
    end
  end
  ...
```

## 03. Collisions
To check if the player collides with one of the walls, we can use DragonRuby's `intersects_rect?` method on our game entities. Let's write a method to check for any collisions and return a boolean:

```ruby
def game_over?
  game.state.obstacles.any? do |o|
    o.rect.intersects_rect?(game.state.player.rect)
  end
end
```

For now, we'll use our `game_over?` method to stop our game state from being updated (so the game will effectively pause):

```ruby
def tick
  set_defaults
  process_inputs
  update_state unless game_over?
  render
end
```

In our render method, add a label to display when the game ends:

```ruby
def render
  ...
  if game_over?
    outputs.labels << [grid.w_half, grid.h_half, "Game Over", 2, 1, 255, 255, 255, 255]
  end
end
```

We can also add a reset feature by resetting the objects if the player presses the R key:

```ruby
def process_inputs
  ...
  if inputs.keyboard.key_down.r
    game.state.obstacles = []
    game.state.obstacle_countdown = 100
  end
end
```

With this code added, we've effectively completed all of the logic for this platformer!

# Extras
## Requiring Files
Create a new file called `game.rb` in the app directory, and move the `Runner` class definition to this file. Back in `main.rb`, add `$dragon.require('app/game.rb')` in `main.rb` to give us access to the code in the `game.rb` file (the normal `require 'game'` syntax won't work). 

_NOTE: DragonRuby's auto-reload feature won't look for changes in files other than `main.rb` so you'll have to restart the DragonRuby instance if you make changes in other files._
