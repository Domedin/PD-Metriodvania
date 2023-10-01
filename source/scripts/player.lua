local pd <const> = playdate
local gfx <const> = playdate.graphics

class('Player').extends(AnimatedSprite)

function Player:init(x, y)
    -- State Machine
    local playerImageTable = gfx.imagetable.new("images/Aesprite/player-table-16-16.aseprite")
    Player.super.init(self, playerImageTable)

    self:addState("idle", 1, 1)
    self:addState("run", 1, 3, {tickStep = 4})
    self:addState("jump", 4, 4)
    self:playAnimation()

    --sprite properties 
    self:moveTo(x, y)
    self:setZIndex(Z_INDEXES.Player)
    self:setTag(TAGS.Player) -- 5, 7 collision rect
    self:setCollideRect(3, 3, 10, 14)

    -- physics properties
    self.xVelocity = 0
    self.yVelocity = 0
    self.gravity = 1
    self.maxSpeed = 4.0

    -- Player State
    self.touchingGround = false
end

function Player:collisionReponse()
    return gfx.sprite.kCollisionTypeSlide
end

function Player:update()
    self:updateAnimation()

    self:handleState()
    self:handleMovementAndCollisions()
end

function Player:handleState()
    if self.currentState == "idle" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "run" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "jump" then
        
    end
end

function Player:handleMovementAndCollisions()
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)

    self.touchingGround = false
    for i=1, length do
        local collision = collisions[i]
        if collision.normal.y == -1 then
            self.touchingGround = true
        end
    end

    if self.xVelocity < 0 then
        self.globalFlip = 1
    elseif self.xVelocity > 0 then
        self.globalFlip = 0
    end
end

-- Input helper functions
function Player:handleGroundInput()
    if pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToRunState("left")
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:changeToRunState("right")
    else
        self:changeToIdleState()
    end
end

-- State transistions
function Player:changeToIdleState()
    self.xVelocity = 0
    self:changeState("idle")
end

function Player:changeToRunState(direction)
    if direction == "left" then
        self.xVelocity = -self.maxSpeed
        self.globalFlip = 1
    elseif direction == "right" then
        self.xVelocity = self.maxSpeed
        self.globalFlip = 0
    end
    self:changeState("run")
    
end

function Player:applyGravity()
    self.yVelocity += self.gravity
    if self.touchingGround then
        self.yVelocity = 0
    end
end