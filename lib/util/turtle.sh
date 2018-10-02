import util/class UI/Curosor util/exception

# TODO: This class should extend 'UI.Curosor' class.
#       In that case, better to have [UI.Cursor] instead of [integer] x or [integer] y
class:Turtle() {
  private integer x
  private integer y
  private bool is_down
  private string pen_type

  Turtle.__init__() {
    [string] pen_type

    [ ${#pen_type} -ne 1 ] && e="invalid length of pen_type" throw

    this x = 0
    this y = 0
    this pen_type = "A"

    @return
  }

  Turtle.capture() {
    local x
    local y
    IFS=';' read -sdR -p $'\E[6n' y x

    this y = $(( ${y#*[} - 1 ))
    this x = $(( ${x} - 1 ))

    @return
  }

  # move to `x` `y`
  # @param <int x> <int y>
  Turtle.move() {
   [integer] x
   [integer] y

   if $(this pen_type); then
     # TODO: draw line to the position
     :
   else
     tput cup $x $y
     this capture
   fi

   @return
  }

  # set to draw the pen
  Turtle.penDown() {
    this is_down = true

    @return
  }

  # set not to draw the pen
  Turtle.penUp() {
    this is_down = false

    @return
  }

  # move to RIGHT for `x` letters
  # @param <int x>
  Turtle.moveRight() {
    [integer] x

    if $(this pen_type); then
      for ((local i=0;i < $x;i++ )); do
        echo -n "$(this pen_type)"
      done
    else
      tput cuf $x
    fi
    this capture

    @return
  }

  # move to LEFT for `x` letters
  # @param <int x>
  Turtle.moveLeft() {
    [integer] x

    if $(this pen_type); then
      for ((local i=0;i < $x;i++ )); do
        tput cub 1
        echo -n "$(this pen_type)"
        tput cub 1
      done
    else
      tput cub $x
    fi
    this capture

    @return
  }

  # move Up  for `y` letters
  # @param <int y>
  Turtle.moveUp() {
    [integer] y

    if $(this pen_type); then
      for ((local i=0;i < $y;i++ )); do
        echo -n "$(this pen_type)"
        tput cuu 1
        tput cub 1
      done
    else
      tput cuu $y
    fi
    this capture

    @return
  }

  # move Up  for `y` letters
  # @param <int y>
  Turtle.moveDown() {
    [integer] y

    if $(this pen_type); then
      for ((local i=0;i < $y;i++ )); do
        echo -n "$(this pen_type)"
        tput cud 1
        tput cub 1
      done
    else
      tput cud $y
    fi
    this capture
    @return
  }

}

Type::Initialize Turtle
