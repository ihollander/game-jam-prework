class Runner
  attr_accessor :game, :grid, :outputs, :inputs

  def tick
    set_defaults
    render
    process_inputs
    update_state unless game_over?
  end

  def set_defaults
    # obstacles
    game.state.obstacles ||= []
    game.state.obstacle_countdown ||= 100

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

  def process_inputs
    if inputs.keyboard.key_down.space && !game.state.player.jumping
      game.state.player.jumping = true
      game.state.player.dy = 15
    end
    if inputs.keyboard.key_down.r
      game.state.obstacles = []
      game.state.obstacle_countdown = 100
    end
  end

  def update_state
    ### calculate new state on each tick
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

    # decrement countdown
    game.state.obstacle_countdown -= 1

    # move the obstacles left 8 pixels each frame
    game.state.obstacles.each { |w| w.rect[0] -= 8 }
    
    # remove the obstacles if they leave the screen
    game.state.obstacles.reject! { |w| w.rect[0] < -w.rect[2] }

    # generate a new obstacle each 100 ticks
    if game.state.obstacle_countdown == 0
      # reset the countdown
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

  def game_over?
    game.state.obstacles.any? do |o|
      o.rect.intersects_rect?(game.state.player.rect)
    end
  end

  def render
    # draw a black background
    outputs.solids << grid.rect # grid.rect == [grid.left, grid.top, grid.bottom, grid.right]
    # draw the floor
    outputs.solids << [grid.left, grid.bottom, grid.right, 60, 255, 0, 0, 255]

    # draw the obstacles
    game.state.obstacles.each do |obstacle| 
      outputs.solids << obstacle.rect
    end

    # draw the player
    outputs.solids << game.state.player.rect

    if game_over?
      outputs.labels << [grid.w_half, grid.h_half, "Game Over", 2, 1, 255, 255, 255, 255]
    end
  end
end

# create our game instance
$runner = Runner.new

# main DragonRuby game loop
def tick args
  print self.public_methods.sort.to_s + "\r" if args.game.tick_count % 5000 == 1
  # pass info from DragonRuby tick to game instance
  $runner.game    = args.game
  $runner.grid    = args.grid
  $runner.outputs = args.outputs
  $runner.inputs  = args.inputs

  # invoke tick on the game
  $runner.tick
end