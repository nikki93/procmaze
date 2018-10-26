local classic = require "https://raw.githubusercontent.com/rxi/classic/master/classic.lua"
local letters = require "./letters"

Object = classic

Game = {}

local WIDTH = 100
local HEIGHT = 65
local SIZE = 9
local LINE_WIDTH = 3
local LINE_STYLE = "rough"

function love.load()
  Game.maze = Maze(WIDTH, HEIGHT)
  print(string.format("Made a maze of size %d, %d", WIDTH, HEIGHT))
end

function love.draw()
  Game.maze:draw(10, 10, SIZE)
end

local interval = 0.01
local dtotal = 0 -- this keeps track of how much time has passed
function love.update(dt)
  for i = 1, 100 do
    Game.maze:onePrim()
  end

  -- dtotal = dtotal + dt -- we add the time passed since the last update, probably a very small number like 0.01
  -- if dtotal >= interval then
  --   dtotal = dtotal - interval -- reduce our timer by a second, but don't discard the change... what if our framerate is 2/3 of a second?
  --   Game.maze:onePrim()
  -- end
end

Cell = Object:extend()

World = Object:extend()

function Cell:new(label)
  self.walls = {
    top = true,
    bottom = true,
    left = true,
    right = true
  }
  self.label = label
  self.visited = false
  self.neighbors = {
    top = nil,
    bottom = nil,
    left = nil,
    right = nil
  }
end

function Cell:draw(x, y, size)
  love.graphics.setLineWidth(LINE_WIDTH)
  love.graphics.setLineStyle(LINE_STYLE)
  if self.walls.top then
    love.graphics.line(x, y, x + size, y)
  end
  if self.walls.bottom then
    love.graphics.line(x, y + size, x + size, y + size)
  end
  if self.walls.left then
    love.graphics.line(x, y, x, y + size)
  end
  if self.walls.right then
    love.graphics.line(x + size, y, x + size, y + size)
  end
  -- love.graphics.print(self.label or "", x + 2, y + 2)
end

Maze = Object:extend()

Walls = {"top", "bottom", "left", "right"}

function Maze:new(width, height)
  self.maze = self.makeFresh(width, height)
  self.width = width
  self.height = height
  self.wallList = {}
  -- Pick a random cell, make it part of the maze
  local x = math.random(1, self.width)
  local y = math.random(1, self.height)
  local randomCell = self.maze[x][y]
  randomCell.visited = true

  -- Add walls to wall list
  for i, d in ipairs(Walls) do
    if randomCell.walls[d] then
      table.insert(self.wallList, {randomCell, d})
    end
  end
end

function oppositeWall(direction)
  return ({
    top = "bottom",
    bottom = "top",
    left = "right",
    right = "left"
  })[direction]
end

function Maze:onePrim()
  -- print("onePrim", #self.wallList)
  -- If wall list is empty then return
  if table.getn(self.wallList) == 0 then
    return
  end

  -- Pick a random wall from the list
  local randomIndex = math.random(1, table.getn(self.wallList))
  local randomWall = self.wallList[randomIndex]

  -- If only one of the two cells that the wall divised is visited then
  local wallCell = randomWall[1]
  local wallDirection = randomWall[2]
  local neighborCell = wallCell.neighbors[wallDirection]
  if not (not neighborCell) then
    local visited = 0
    if wallCell.visited then
      visited = visited + 1
    end
    if neighborCell.visited then
      visited = visited + 1
    end
    if visited == 1 then
      -- Make the wall a passage and mark the unvisited cell as part of the maze
      wallCell.walls[wallDirection] = false
      neighborCell.walls[oppositeWall(wallDirection)] = false
      wallCell.visited = true
      neighborCell.visited = true

      -- Add the neighboring walls of the cell to the wall list
      for i, d in ipairs(Walls) do
        if neighborCell.walls[d] then
          table.insert(self.wallList, {neighborCell, d})
        end
      end
    end
  end
  -- Remove wall from the wall list
  table.remove(self.wallList, randomIndex)
end

function Maze:draw(x, y, size)
  for i = 1, self.width do
    for j = 1, self.height do
      self.maze[i][j]:draw(x + (i - 1) * size, y + (j - 1) * size, size)
    end
  end
end

function Maze.makeFresh(width, height)
  local maze = {}
  for i = 1, width do
    maze[i] = {}
    for j = 1, height do
      maze[i][j] = Cell(string.format("%d,%d", i, j))
    end
  end

  for i = 1, width do
    for j = 1, height do
      local cell = maze[i][j]
      if i > 1 then
        cell.neighbors.left = maze[i - 1][j]
      end
      if i < width then
        cell.neighbors.right = maze[i + 1][j]
      end
      if j > 1 then
        cell.neighbors.top = maze[i][j - 1]
      end
      if j < height then
        cell.neighbors.bottom = maze[i][j + 1]
      end
    end
  end

  local function filler(ox, oy)
    local function fill(x, y)
      maze[x + ox][y + oy].visited = true
    end
    return fill
  end

  local fill = filler(2, 2)
  fill(0, 0)
  fill(0, 1)
  fill(0, 2)
  fill(0, 3)
  fill(0, 4)
  fill(1, 0)
  fill(2, 0)
  fill(1, 2)
  fill(2, 2)
  fill(1, 4)
  fill(2, 4)

  local fill = filler(6, 2)
  fill(0, 0)
  fill(4, 0)
  fill(1, 1)
  fill(3, 1)
  fill(0, 4)
  fill(4, 4)
  fill(1, 3)
  fill(3, 3)
  fill(2, 2)

  local fill = filler(12, 2)
  fill(0, 0)
  fill(1, 0)
  fill(2, 0)
  fill(0, 1)
  fill(2, 1)
  fill(0, 2)
  fill(1, 2)
  fill(2, 2)
  fill(0, 3)
  fill(0, 4)

  local fill = filler(16, 2)
  fill(0, 0)
  fill(1, 0)
  fill(2, 0)
  fill(0, 1)
  fill(2, 1)
  fill(0, 2)
  fill(2, 2)
  fill(0, 3)
  fill(2, 3)
  fill(0, 4)
  fill(1, 4)
  fill(2, 4)


  return maze
end
