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

      # TODO: rename this variable.It's terrible omg
      local value_without_e=${value%e*}
      # I need to re-define this[0], otherwise it will be ( [0]="[0]=2D6A822E666126156174010" [1]=... )
      # TODO: find someway to remove this code
      unset this
      this[0]=${__primitive_extension_fingerprint__float}
      this[1]="${value_without_e/./}"
      this[2]="$exponent"
      ;;
    [0-9.]* )
      local integer_digits=${value%.*}
      local -i number_of_integer_digits=${#integer_digits}

      # TODO: find someway to remove this code(same as above)
      unset this
      this[0]=${__primitive_extension_fingerprint__float}
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
