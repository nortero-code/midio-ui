import options
import ../element
import ../../vec
import ../../rect
import ../../thickness
import ../../utils
import ../../type_name

type
  Stack* = ref object of Element
    stackProps*: StackProps

  StackDirection* = enum
    Vertical, Horizontal

  StackProps* = ref object
    direction*: StackDirection

implTypeName(Stack)

method measureOverride(self: Stack, availableSize: Vec2[float]): Vec2[float] =
  let props = self.stackProps
  var width = 0.0
  var accumulatedHeight = 0.0
  let isVertical = props.direction == StackDirection.Vertical
  for child in self.children:
    child.measure(choose(isVertical, availableSize.withY(INF), availableSize.withX(INF)))
    if child.desiredSize.isSome():
      width = max(width, choose(isVertical, child.desiredSize.get().x, child.desiredSize.get().y))
      accumulatedHeight += choose(isVertical, child.desiredSize.get().y, child.desiredSize.get().x)
    else:
      echo "WARN: Child of stack did not have a desired size"

  choose(isVertical, vec2(width, accumulatedHeight), vec2(accumulatedHeight, width))

method arrangeOverride(self: Stack, availableSize: Vec2[float]): Vec2[float] =
  let props = self.stackProps
  var nextPos = vec2(0.0, 0.0)
  let isVertical = props.direction == StackDirection.Vertical
  var size = if isVertical:
               availableSize.withY(0.0)
             else:
               availableSize.withX(0.0)
  for child in self.children:
    if child.desiredSize.isSome():
      child.arrange(
        rect(
          nextPos,
          choose(
            isVertical,
            vec2(availableSize.x, child.desiredSize.get().y),
            vec2(child.desiredSize.get().x, availableSize.y)
          )
        )
      )
      nextPos = choose(isVertical, nextPos.addY(child.desiredSize.get().y), nextPos.addX(child.desiredSize.get().x))
      if isVertical:
        size = size + child.desiredSize.get().withX(0.0)
      else:
        size = size + child.desiredSize.get().withY(0.0)
    else:
      echo "WARN: Child of stack did not have a desired size"
  size

proc initStack*(self: Stack, props: StackProps): void =
  self.stackProps = props

proc createStack*(props: (ElementProps, StackProps)): Stack =
  result = Stack()
  initElement(result, props[0])
  initStack(result, props[1])
