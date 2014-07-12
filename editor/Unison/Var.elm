module Unison.Var where

import Unison.Jsonify as J
import Unison.Parser as P

type I = Int

parse : P.Parser I
parse = P.int

jsonify : J.Jsonify I
jsonify i = J.number (toFloat i)