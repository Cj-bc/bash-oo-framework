import util/class

# TODO: 'move*' methods are too slow

class:UI.Cursor() {
  # http://askubuntu.com/questions/366103/saving-more-corsor-positions-with-tput-in-bash-terminal
	# http://unix.stackexchange.com/questions/88296/get-vertical-cursor-position

	private integer x
	private integer y

  UI.Cursor.capture() {
    local x
    local y
    IFS=';' read -sdR -p $'\E[6n' y x

    this y = $(( ${y#*[} - 1 ))
    this x = $(( ${x} - 1 ))

    @return
  }

  UI.Cursor.restore() {
    [integer] shift=1

    local -i totalHeight=$(tput lines)
    local -i y=$(this y)
    local -i x=$(this x)

    (( $y + 1 == $totalHeight )) && y+=-$shift

    tput cup $y $x

    @return
  }

  # move to `x` `y`
  # @param <int x> <int y>
  UI.Cursor.move() {
   [integer] x
   [integer] y

   tput cup $x $y
   this capture

   @return
  }

  # move to RIGHT for `x` letters
  # @param <int x>
  UI.Cursor.moveRight() {
    [integer] x

    tput cuf $x
    this capture

    @return
  }

  # move to LEFT for `x` letters
  # @param <int x>
  UI.Cursor.moveLeft() {
    [integer] x

    tput cub $x
    this capture

    @return
  }

  # move Up  for `y` letters
  # @param <int y>
  UI.Cursor.moveUp() {
    [integer] y

    tput cuu $y
    this capture

    @return
  }

  # move Up  for `y` letters
  # @param <int y>
  UI.Cursor.moveDown() {
    [integer] y

    tput cud $y
    this capture
    @return
  }
}

Type::Initialize UI.Cursor
