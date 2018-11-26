# author: Cj-bc
import util/namedParameters util/type float

namespace oo/type

#
# float type construction:
#   this[0]: fingerprint
#   this[1]: decimal part
#   this[2]: exponent part

float.__getter__() {
  echo "${this[@]}"
  @return
}
# can treat both of '123.456' and '1.23456e2'
float.=() {
  [string] value
  case $1 in
    [0-9.]*e[-0-9]* )
      local integer_digits=${value%.*}
      local -i number_of_integer_digits=${#integer_digits}
      local -i exponent=${value#*e}
      [[ $number_of_integer_digits -ne 1 ]] && exponent+=$((number_of_integer_digits - 1))
      this[1]="${value/./}"
      this[2]="$exponent"
      ;;
    [0-9.]* )
      local integer_digits=${value%.*}
      local -i number_of_integer_digits=${#integer_digits}
      this[1]="${value/./}"
      this[2]=$((number_of_integer_digits - 1))
      ;;
    *) :;;
  esac

  @return
}

# float.+() {
#   :
# }
# 
# float.-() {
#   :
# }
# 
# float.*() {
#   :
# }
# 
# float./() {
#   :
# }
# 
# float.+=() {
#   :
# }
# 
# float.-=() {
#   :
# }


Type::InitializePrimitive float
