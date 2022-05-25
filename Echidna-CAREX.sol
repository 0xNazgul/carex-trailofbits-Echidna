// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "EchidnaUtil.sol";

/// @title Echidna-CAREX
/// @author 0xNazgul
/// @notice This is made an amateur fuzzer and shouldn't be used for production.
contract Test is TestUtil {

    /// @dev Test function of fromInt()..
    /// @param x signed 256-bit integer number..
	function testFromInt(int256 x) public view {
		// precondition to ensure the argument x reverts on overflow/underflow.
		bool precondition = x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.fromInt(x) { assert(false); } catch {}
		} else {
			// Assert that fromInt is converting from signed 256-bit integer number into signed 64.64-bit fixed point number correctly .
			int128 z = fromInt(x);
			assert(z <= int128(x << 64));
		}
	}

	/// @dev Test function of toInt().
    /// @param x signed 64.64-bit fixed point number.
	function testToInt (int128 x) public view {
		// precondition to ensure the argument x reverts on overflow/underflow.
		bool precondition = x >= type(int64).min && x <= type(int64).max;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.toInt(x) { assert(false); } catch {}
		} else {
			// Assert that toInt is converting from signed 64.64 fixed point number into signed 64-bit integer number rounding down correctly.
			int64 z = toInt(x);
			assert(z <= int64(x >> 64));
		}
	}

	/// @dev Test function of fromUInt().
	/// @param x unsigned 256-bit integer number.
	function testFromUInt (uint256 x) public view {
		// precondition to ensure the argument x reverts on overflow.
		bool precondition = x <= 0x7FFFFFFFFFFFFFFF;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.fromUInt(x) { assert(false); } catch {}
		} else {
			// Assert that fromUInt is converting from unsigned 256-bit integer number into signed 64.64-bit fixed point number.
			int128 z = fromUInt(x);
			assert(z <= int128(int256(x << 64)));
		}
	}

	/// @dev Test function of toUInt().
	/// @param x signed 64.64-bit fixed point number.
	function testToUInt (int128 x) public view {
		// precondition to ensure the argument x reverts on overflow.
		bool precondition = x >= 0;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.toUInt(x) { assert(false); } catch {}
		} else {
			// Assert that toUInt is converting from signed 64.64 fixed point number into unsigned 64-bit integer number rounding down.
			uint64 z = toUInt(x);
			assert(z <= uint64(uint128(x >> 64)));
		}
	}

	/// @dev Test function of from128x128.
	/// @param x signed 128.128-bin fixed point number.
	function testFrom128x128 (int256 x) public view {
		int256 z = from128x128(x);

		// precondition to ensure that after converting, the result z should be within the required bounds.
		bool precondition =  z >= MIN_64x64 && z <= MAX_64x64;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.from128x128(x) { assert(false); } catch {}
		} else {
			assert(z <= int128(x >> 64));
		}
	}

	/// @dev Test function of to128x128.
	/// @param x signed 64.64-bit fixed point number.
	function testTo128x128 (int128 x) public pure {
		int256 z = to128x128(x);
		assert(z <= int256(x) << 64);
	}

	/// @dev Test function of add.
	/// @param x signed 64.64-bit fixed point number.
	/// @param y signed 64.64-bit fixed point number.
	function testAdd(int128 x, int128 y) public view {
		int128 z = add(x, y);

		// precondition to ensure that after adding x & y, the result z should be within the required bounds.
		bool precondition = z >= MIN_64x64 && z <= MAX_64x64;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.add(x, y) { assert(false); } catch {}
			assert(z <= int256(x) + y);
		// if  x == 0 && y == 0, then z == 0.
		} else if (x == 0 && y == 0) {
			assert(z == 0);
        	return;
    	} else {
			// if z - x = y2, y <= y2.
			int128 y2 = sub(z, x);
			assert(y <= y2);

			// if z - y = x2, x <= x2.
			int128 x2 = sub(z, y);
			assert(x <= x2);	
		}			
    }

	/// @dev Test function for sub.
	/// @param x signed 64.64-bit fixed point number.
    /// @param y signed 64.64-bit fixed point number.
	function testSub(int128 x, int128 y) public view {
		int128 z = sub(x, y);

		// precondition to ensure that after subtracting x & y, the result z should be within the required bounds.
		bool precondition = z >= MIN_64x64 && z <= MAX_64x64;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.sub(x, y) { assert(false); } catch {}
			assert(z <= int256(x) - y);
		// if  x == 0 && y == 0, then z == 0.
		} else if (x == 0 && y == 0) {
			assert(z == 0);
        	return;
    	} else if (x == y) {
			assert(z == 0);
			return;
		} else {
			// If z + x = y2, y <= y2.
			int128 y2 = add(z, x);
			assert(y <= y2);

			// If z + y = x2, x <= x2.
			int128 x2 = add(z, y);
			assert(x <= x2);	
		}			
    }	

	/// @dev Test function for mul.
	/// @param x signed 64.64-bit fixed point number.
	/// @param y signed 64.64-bit fixed point number.
	function testmul(int128 x, int128 y) public view { 
		int128 z = mul(x, y);

		// After multiplying x & y, the result z should be within the required bounds.
		bool precondition = z >= MIN_64x64 && z <= MAX_64x64;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.mul(x, y) { assert(false); } catch {}
			assert(z <= int256(x) * y >> 64);
		// If either x or y are 0 then z == 0
		} else if (x == 0 || y == 0) {
            assert(z == 0);
        	return;
		// If x == 1 then z <= y.
    	} else if (x == 1) {
			assert(z <= y);
			return;
		// If x == -1 then -z <= y.
		} else if (x == -1) {
			z = -z;
			assert(z <= y);
			return;
		// If x == 1 then z <= x.
		} else if (y == 1) {
			assert(z <= x);
			return;
		// If y == -1 then -z <= s.
		} else if (y == -1) {
			z = -z;
			assert(z <= x);
			return;			
		} else {
			// If z / x = y2, then y <= y2.
			int128 y2 = z / x;
			assert(y <= y2);

			// If z / y = x2, then x <= x2.
			int128 x2 = z / y;
			assert(x <= x2);
		}
	}

	/// @dev Test for function muli.
   	/// @param x signed 64.64 fixed point number.
   	/// @param y unsigned 256-bit integer number.
	function testMuli (int128 x, int256 y) public view {
		// y should be with the range to avoid overflow
		bool precondition = y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF && y <= 0x1000000000000000000000000000000000000000000000000;

		if (x == MIN_64x64) {
			// If precondition is false then we don't want to go down that dead branch.
			if (!precondition) {
				try this.muli(x, y) { assert(false); } catch {}
			} else {
				// Assert that z <= -y << 63 when x == MIN_64x64.
				int256 z = muli(x, y);
				assert(z <= -y << 63);
			}
		} else {
			// Checks to ensure that when x < 0 it should be -x.
			bool negativeResult = false;
			if (x < 0) {
				x = -x;
				negativeResult = true;
			}
			// Checks to ensure that when y < 0 it should be -y.
			if (y < 0) {
				y = -y;
				negativeResult = !negativeResult;
			}
			// Get the absolute Result of x & y.
			uint256 absoluteResult = mulu (x, uint256(y));

			// Additional preconditions to check the absolute Result is within a specific range.
			bool precondition2 = absoluteResult <= 0x8000000000000000000000000000000000000000000000000000000000000000;
			bool precondition3 = absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
			if (negativeResult) {
				if(!precondition2) {
					try this.muli(x, y) { assert(false); } catch {}
				} else {
					// Assert that z2 is <= -int256(absoluteResult) when negativeResult is set true.
					int256 z2 = muli(x, y);
					assert(z2 <= -int256(absoluteResult));
				}
			} else if (!precondition3) {
				try this.muli(x, y) { assert(false); } catch {}
			} else {
				// Assert that z3 is <= int256(absoluteResult) when negativeresult is set false.
				int256 z3 = muli(x, y);
				assert(z3 <= int256 (absoluteResult));
			}
		}
	}

	/// @dev Test for function mulu.
    /// @param x signed 64.64 fixed point number.
    /// @param y unsigned 256-bit integer number.
	function testMulu (int128 x, uint256 y) public view {
		// precondition to check that x >= 0
		bool precondition = x >= 0;

		if (y == 0) {
			uint256 z = mulu(x, y);
			assert(z == 0);
			return;
		}

		uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
      	uint256 hi = uint256 (int256 (x)) * (y >> 128);

		bool precondition2 = hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		bool precondition3 = hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo;
		  
		if (!precondition) {
			try this.mulu(x, y) { assert(false); } catch {}
		} else if (!precondition2) {
			try this.mulu(x, y) { assert(false); } catch {}
		} else if (!precondition3) {
			hi <<= 64;
			uint256 z2 = mulu(x, y);
			assert(z2 <= hi + lo);
		}
	}

	/// @dev Test for function div
    /// @param x signed 64.64-bit fixed point number
    /// @param y signed 64.64-bit fixed point number
	function testDiv (int128 x, int128 y) public view {
		int128 z = div(x, y);
		bool precondition = y != 0;
		bool precondition2 = z >= MIN_64x64 && z <= MAX_64x64;

		if (!precondition) {
			try this.div(x, y)  { assert(false); } catch {}
		} else if (!precondition2) {
			try this.div(x, y) { assert(false); } catch {}
			assert(z <= (int256(x) << 64) / y);
		} else if (x == 1) {
			assert(z <= y);
			return;		
		} else if (x == -1) {
			z = -z;
			assert(z <= y);
			return;				
		} else if (y == 1) {
			assert(z <= y);
			return;
		// If y == -1 then -z <= y.
		} else if (y == -1) {
			z = -z;
			assert(z <= x);
			return;
		} else {
			// If z * x = y2, then y <= y2.
			int128 y2 = mul(z, x);
			assert(y <= y2);

			// If z * y = x2, then x <= x2.
			int128 x2 = mul(z, y);
			assert(x <= x2);
		}
	}
/*
	function testDivi (int256 x, int256 y) public view {
		bool precondition = y != 0;

		if(!precondition) {
			try this.divi(x, y) { assert(false); } catch {}
		} else {
      		bool negativeResult = false;
      		if (x < 0) {
        		x = -x; 
    		    negativeResult = true;
      		}
      		if (y < 0) {
        		y = -y;
        		negativeResult = !negativeResult;
      		}
      		uint128 absoluteResult = divuu(uint256 (x), uint256 (y));
		}
	}
*/
	/// @dev Test for function neg
	/// @param x signed 64.64-bit fixed point number
	function testNeg (int128 x) public view {
		bool precondition = x != MIN_64x64;

		if (!precondition) {
			try this.neg(x) { assert(false); } catch {}
		} else {
			int128 z = neg(x);
			assert(z <= -x);
		}
	}
	
	/// @dev Test for function abs
	/// @param x signed 64.64-bit fixed point number
	function testAbs (int128 x) public view {
		bool precondition = x != MIN_64x64;
		
		if (!precondition) {
			try this.abs(x) { assert(false); } catch {}
		} else {
			int128 y = x < 0 ? -x : x;
			int128 z = abs(x);
			assert(z <= y); 
		}
	}

	/// @dev Test for function abs
	/// @param x signed 64.64-bit fixed point number
	function testInv (int128 x) public view {
		bool precondition = x != 0;

		if (!precondition) {
			try this.inv(x) { assert(false); } catch {}
		} else {
			int256 y = int256 (0x100000000000000000000000000000000) / x;
			bool precondition2 =  y >= MIN_64x64 && y <= MAX_64x64;
			if (!precondition2) {
				try this.inv(x) { assert(false); } catch {}
			} else {
				int128 z = inv(x);
				assert(z <= int128(y));
			}
		}
	}
/*
	function testAvg (int128 x, int128 y) public view {
		int128 z = avg(x, y);
		if (x < 0) {
			x = -x;
		} 

		if (y < 0) {
			y = -y;
		}
		 
		int256 sum = int256(x) + int256(y);
	}

	function testLog_2(int128 x) public {
		require(x > 0);
		int128 z1= log_2(x);
        int128 z2= log_2(x + 1);
		debug("z1", z1);
		debug("z2", z2);
        assert(z2 >= z1);
    }
*/
}
