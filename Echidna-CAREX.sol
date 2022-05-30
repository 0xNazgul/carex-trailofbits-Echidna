// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import "EchidnaUtil.sol";

/// @title Echidna-CAREX
/// @author 0xNazgul.
/// @notice This is made an amateur fuzzer and shouldn't be used for production.
/// @notice No tests are done for pow() && log_2.
contract Test is TestUtil {

    /// @dev Test function of fromInt().
    /// @param x signed 256-bit integer number.
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
	function testToInt(int128 x) public pure {
		if (x >= 0) {
    		// Assert that toInt is converting from signed 64.64 fixed point number into signed 64-bit integer number rounding down correctly.
			int64 z = toInt(x);
			assert(z <= int64(x >> 64));
		} else {
			// Assert that toInt is converting from signed 64.64 fixed point number into signed 64-bit integer number rounding down correctly.
			int64 z = -toInt(neg(x));
			assert(z <= -int64(x >> 64));
   		}
	}

	/// @dev Test function of fromUInt().
	/// @param x unsigned 256-bit integer number.
	function testFromUInt(uint256 x) public view {
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
	function testToUInt(int128 x) public view {
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
	function testFrom128x128(int256 x) public view {
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
	function testTo128x128(int128 x) public pure {
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
	function testMul(int128 x, int128 y) public view { 
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
	function testMuli(int128 x, int256 y) public view {
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
	function testMulu(int128 x, uint256 y) public view {
		// precondition to check that x >= 0
		bool precondition = x >= 0;

		if (y == 0) {
			uint256 z = mulu(x, y);
			assert(z == 0);
			return;
		}
		// Calculate lo and hi to be used in further preconditions.
		uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
      		uint256 hi = uint256 (int256 (x)) * (y >> 128);

		bool precondition2 = hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
		bool precondition3 = hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo;
		// If precondition is false then we don't want to go down that dead branch.  
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

	/// @dev Test for function div.
    	/// @param x signed 64.64-bit fixed point number.
    	/// @param y signed 64.64-bit fixed point number.
	function testDiv(int128 x, int128 y) public view {
		int128 z = div(x, y);
		
		bool precondition = y != 0;
		bool precondition2 = z >= MIN_64x64 && z <= MAX_64x64;

		// If precondition is false then we don't want to go down that dead branch.
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

	/// @dev Test for function divi.
	/// @param x signed 256-bit integer number
    	/// @param y signed 256-bit integer number
	function testDivi (int256 x, int256 y) public view {
		bool precondition = y != 0;

		// If precondition is false then we don't want to go down that dead branch.
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
			bool precondition2 = absoluteResult <= 0x80000000000000000000000000000000;
			bool precondition3 = absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
			if(negativeResult) {
				if(!precondition2) {
					try this.divi(x, y) { assert(false); } catch {}
				} else {
					int128 z = divi(x, y);
					int128 z2 = -int128(absoluteResult);
					assert(z <= z2);
				}
			} else {
				if(!precondition3) {
					try this.divi(x, y) { assert(false); } catch {}
				} else {
					int128 z = divi(x, y);
					int128 z2 = int128(absoluteResult);
					assert(z <= z2);
				}
			}
		}
	}

	/// @dev Test for function divu.
	/// @param x unsigned 256-bit integer number
   	/// @param y unsigned 256-bit integer number
	function testDivu (uint256 x, uint256 y) public view {
		bool precondition = y != 0;
		uint128 result = divuu (x, y);
		bool precondition2 = result <= uint128(MAX_64x64);

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.divu(x, y) { assert(false); } catch {}
		} else if(!precondition2) {
			try this.divuu(x, y) { assert(false); } catch {}
		} else {
			int128 z = divu(x, y);
			int128 z2 = int128(result);
			assert(z <= z2);
		}
	}

	/// @dev Test for function neg.
	/// @param x signed 64.64-bit fixed point number.
	function testNeg(int128 x) public view {
		bool precondition = x != MIN_64x64;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.neg(x) { assert(false); } catch {}
		} else {
			int128 z = neg(x);
			assert(z <= -x);
		}
	}
	
	/// @dev Test for function abs.
	/// @param x signed 64.64-bit fixed point number.
	function testAbs(int128 x) public view {
		bool precondition = x != MIN_64x64;
		
		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.abs(x) { assert(false); } catch {}
		} else {
			int128 y = x < 0 ? -x : x;
			int128 z = abs(x);
			assert(z <= y); 
		}
	}

	/// @dev Test for function inv.
	/// @param x signed 64.64-bit fixed point number.
	function testInv(int128 x) public view {
		bool precondition = x != 0;

		// If precondition is false then we don't want to go down that dead branch.
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

	/// @dev Test for function avg.
    	/// @param x signed 64.64-bit fixed point number.
    	/// @param y signed 64.64-bit fixed point number.
	function testAvg(int128 x, int128 y) public pure {
		int128 z = avg(x, y);		 
		int256 sum = int128((int256(x) + int256(y)) >> 1);
		assert(z <= sum);
	}

	/// @dev Test for function gavg.
    	/// @param x signed 64.64-bit fixed point number.
    	/// @param y signed 64.64-bit fixed point number.
	function testGavg(int128 x, int128 y) public view {
		int256 z = int256(x) * int256(y);

		bool precondition = z >= 0;
		bool precondition2 = z < 0x4000000000000000000000000000000000000000000000000000000000000000;

		// If both preconditions are false then we don't want to go down that dead branch.
		if(!precondition && !precondition2) {
			try this.gavg(x, y) { assert(false); } catch {}
		} else {
			int128 z2 = int128(sqrtu(uint256(z)));
			assert(z <= z2);
		}
	}	

	/// @dev Test for function sqrt.
	/// @param x signed 64.64-bit fixed point number.
	function testSqrt(int128 x) public view {
		bool precondition = x >= 0;

		// If precondition is false then we don't want to go down that dead branch.
		if(!precondition) {
			try this.sqrt(x) { assert(false); } catch {}
		} else {
			int128 z = sqrt(x);
			int128 z2 = int128 (sqrtu (uint256 (int256 (x)) << 64));
			assert(z <= z2);
		}
	}

	/// @dev Test for function ln.
	/// @param x signed 64.64-bit fixed point number.
	function testLn (int128 x) public view {
		bool precondition = x > 0;

		// If precondition is false then we don't want to go down that dead branch.
		if(!precondition) {
			try this.ln(x) { assert(false); } catch {}
		} else {
			int128 z = ln(x);
			int128 z2 = int128 (int256(uint256(int256(log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
			assert(z <= z2);
		}
	}

	/// @dev Test for function exp_2.
	/// @param x signed 64.64-bit fixed point number.
	function testExp_2 (int128 x) public view {
		bool precondition = x < 0x400000000000000000; 
		bool precondition2 = x < -0x400000000000000000;
      	if (!precondition) {
			try this.exp_2(x) { assert(false); } catch {}
		} else if(precondition2) {
			int128 z = exp_2(x);
			assert(z == 0);
		} else {
			// Converting result of exp_2 back to uint256.
			uint256 z = uint256(int256(exp_2(x)));
			// undoing the result to before the if statements.
			z <<= uint256(int256(63 + (x << 64)));
			
			uint256 result = 0x80000000000000000000000000000000;
			// Doing all the same if statements.
			if (x & 0x8000000000000000 > 0)
				// Undoing the shift and dividing instead of multiplying.
				z = (z << 128) / 0x16A09E667F3BCC908B2FB1366EA957D3E;
				// Asserting that z is <= to the result
				assert(z <= result);
			if (x & 0x4000000000000000 > 0)
				z = (z << 128) / 0x1306FE0A31B7152DE8D5A46305C85EDEC;
				assert(z <= result);
			if (x & 0x2000000000000000 > 0)
				z = (z << 128) / 0x1172B83C7D517ADCDF7C8C50EB14A791F;
				assert(z <= result);
			if (x & 0x1000000000000000 > 0)
				z = (z << 128) / 0x10B5586CF9890F6298B92B71842A98363;
				assert(z <= result);
			if (x & 0x800000000000000 > 0)
				z = (z << 128) / 0x1059B0D31585743AE7C548EB68CA417FD;
				assert(z <= result);
			if (x & 0x400000000000000 > 0)
				z = (z << 128) / 0x102C9A3E778060EE6F7CACA4F7A29BDE8;
				assert(z <= result);
			if (x & 0x200000000000000 > 0)
				z = (z << 128) / 0x10163DA9FB33356D84A66AE336DCDFA3F;
				assert(z <= result);
			if (x & 0x100000000000000 > 0)
				z = (z << 128) / 0x100B1AFA5ABCBED6129AB13EC11DC9543;
				assert(z <= result);
			if (x & 0x80000000000000 > 0)
				z = (z << 128) / 0x10058C86DA1C09EA1FF19D294CF2F679B;
				assert(z <= result);
			if (x & 0x40000000000000 > 0)
				z = (z << 128) / 0x1002C605E2E8CEC506D21BFC89A23A00F;
				assert(z <= result);
			if (x & 0x20000000000000 > 0)
				z = (z << 128) / 0x100162F3904051FA128BCA9C55C31E5DF;
				assert(z <= result);
			if (x & 0x10000000000000 > 0)
				z = (z << 128) / 0x1000B175EFFDC76BA38E31671CA939725;
				assert(z <= result);
			if (x & 0x8000000000000 > 0)
				z = (z << 128) / 0x100058BA01FB9F96D6CACD4B180917C3D;
				assert(z <= result);
			if (x & 0x4000000000000 > 0)
				z = (z << 128) / 0x10002C5CC37DA9491D0985C348C68E7B3;
				assert(z <= result);
			if (x & 0x2000000000000 > 0)
				z = (z << 128) / 0x1000162E525EE054754457D5995292026;
				assert(z <= result);
			if (x & 0x1000000000000 > 0)
				z = (z << 128) / 0x10000B17255775C040618BF4A4ADE83FC;
				assert(z <= result);
			if (x & 0x800000000000 > 0)
				z = (z << 128) / 0x1000058B91B5BC9AE2EED81E9B7D4CFAB;
				assert(z <= result);
			if (x & 0x400000000000 > 0)
				z = (z << 128) / 0x100002C5C89D5EC6CA4D7C8ACC017B7C9;
				assert(z <= result);
			if (x & 0x200000000000 > 0)
				z = (z << 128) / 0x10000162E43F4F831060E02D839A9D16D;
				assert(z <= result);
			if (x & 0x100000000000 > 0)
				z = (z << 128) / 0x100000B1721BCFC99D9F890EA06911763;
				assert(z <= result);
			if (x & 0x80000000000 > 0)
				z = (z << 128) / 0x10000058B90CF1E6D97F9CA14DBCC1628;
				assert(z <= result);
			if (x & 0x40000000000 > 0)
				z = (z << 128) / 0x1000002C5C863B73F016468F6BAC5CA2B;
				assert(z <= result);
			if (x & 0x20000000000 > 0)
				z = (z << 128) / 0x100000162E430E5A18F6119E3C02282A5;
				assert(z <= result);
			if (x & 0x10000000000 > 0)
				z = (z << 128) / 0x1000000B1721835514B86E6D96EFD1BFE;
				assert(z <= result);
			if (x & 0x8000000000 > 0)
				z = (z << 128) / 0x100000058B90C0B48C6BE5DF846C5B2EF;
				assert(z <= result);
			if (x & 0x4000000000 > 0)
				z = (z << 128) / 0x10000002C5C8601CC6B9E94213C72737A;
				assert(z <= result);
			if (x & 0x2000000000 > 0)
				z = (z << 128) / 0x1000000162E42FFF037DF38AA2B219F06;
				assert(z <= result);
			if (x & 0x1000000000 > 0)
				z = (z << 128) / 0x10000000B17217FBA9C739AA5819F44F9;
				assert(z <= result);
			if (x & 0x800000000 > 0)
				z = (z << 128) / 0x1000000058B90BFCDEE5ACD3C1CEDC823;
				assert(z <= result);
			if (x & 0x400000000 > 0)
				z = (z << 128) / 0x100000002C5C85FE31F35A6A30DA1BE50;
				assert(z <= result);
			if (x & 0x200000000 > 0)
				z = (z << 128) / 0x10000000162E42FF0999CE3541B9FFFCF;
				assert(z <= result);
			if (x & 0x100000000 > 0)
				z = (z << 128) / 0x100000000B17217F80F4EF5AADDA45554;
				assert(z <= result);
			if (x & 0x80000000 > 0)
				z = (z << 128) / 0x10000000058B90BFBF8479BD5A81B51AD;
				assert(z <= result);
			if (x & 0x40000000 > 0)
				z = (z << 128) / 0x1000000002C5C85FDF84BD62AE30A74CC;
				assert(z <= result);
			if (x & 0x20000000 > 0)
				z = (z << 128) / 0x100000000162E42FEFB2FED257559BDAA;
				assert(z <= result);
			if (x & 0x10000000 > 0)
				z = (z << 128) / 0x1000000000B17217F7D5A7716BBA4A9AE;
				assert(z <= result);
			if (x & 0x8000000 > 0)
				z = (z << 128) / 0x100000000058B90BFBE9DDBAC5E109CCE;
				assert(z <= result);
			if (x & 0x4000000 > 0)
				z = (z << 128) / 0x10000000002C5C85FDF4B15DE6F17EB0D;
				assert(z <= result);
			if (x & 0x2000000 > 0)
				z = (z << 128) / 0x1000000000162E42FEFA494F1478FDE05;
				assert(z <= result);
			if (x & 0x1000000 > 0)
				z = (z << 128) / 0x10000000000B17217F7D20CF927C8E94C;
				assert(z <= result);
			if (x & 0x800000 > 0)
				z = (z << 128) / 0x1000000000058B90BFBE8F71CB4E4B33D;
				assert(z <= result);
			if (x & 0x400000 > 0)
				z = (z << 128) / 0x100000000002C5C85FDF477B662B26945;
				assert(z <= result);
			if (x & 0x200000 > 0)
				z = (z << 128) / 0x10000000000162E42FEFA3AE53369388C;
				assert(z <= result);
			if (x & 0x100000 > 0)
				z = (z << 128) / 0x100000000000B17217F7D1D351A389D40;
				assert(z <= result);
			if (x & 0x80000 > 0)
				z = (z << 128) / 0x10000000000058B90BFBE8E8B2D3D4EDE;
				assert(z <= result);
			if (x & 0x40000 > 0)
				z = (z << 128) / 0x1000000000002C5C85FDF4741BEA6E77E;
				assert(z <= result);
			if (x & 0x20000 > 0)
				z = (z << 128) / 0x100000000000162E42FEFA39FE95583C2;
				assert(z <= result);
			if (x & 0x10000 > 0)
				z = (z << 128) / 0x1000000000000B17217F7D1CFB72B45E1;
				assert(z <= result);
			if (x & 0x8000 > 0)
				z = (z << 128) / 0x100000000000058B90BFBE8E7CC35C3F0;
				assert(z <= result);
			if (x & 0x4000 > 0)
				z = (z << 128) / 0x10000000000002C5C85FDF473E242EA38;
				assert(z <= result);
			if (x & 0x2000 > 0)
				z = (z << 128) / 0x1000000000000162E42FEFA39F02B772C;
				assert(z <= result);
			if (x & 0x1000 > 0)
				z = (z << 128) / 0x10000000000000B17217F7D1CF7D83C1A;
				assert(z <= result);
			if (x & 0x800 > 0)
				z = (z << 128) / 0x1000000000000058B90BFBE8E7BDCBE2E;
				assert(z <= result);
			if (x & 0x400 > 0)
				z = (z << 128) / 0x100000000000002C5C85FDF473DEA871F;
				assert(z <= result);
			if (x & 0x200 > 0)
				z = (z << 128) / 0x10000000000000162E42FEFA39EF44D91;
				assert(z <= result);
			if (x & 0x100 > 0)
				z = (z << 128) / 0x100000000000000B17217F7D1CF79E949;
				assert(z <= result);
			if (x & 0x80 > 0)
				z = (z << 128) / 0x10000000000000058B90BFBE8E7BCE544;
				assert(z <= result);
			if (x & 0x40 > 0)
				z = (z << 128) / 0x1000000000000002C5C85FDF473DE6ECA;
				assert(z <= result);
			if (x & 0x20 > 0)
				z = (z << 128) / 0x100000000000000162E42FEFA39EF366F;
				assert(z <= result);
			if (x & 0x10 > 0)
				z = (z << 128) / 0x1000000000000000B17217F7D1CF79AFA;
				assert(z <= result);
			if (x & 0x8 > 0)
				z = (z << 128) / 0x100000000000000058B90BFBE8E7BCD6D;
				assert(z <= result);
			if (x & 0x4 > 0)
				z = (z << 128) / 0x10000000000000002C5C85FDF473DE6B2;
				assert(z <= result);
			if (x & 0x2 > 0)
				z = (z << 128) / 0x1000000000000000162E42FEFA39EF358;
				assert(z <= result);
			if (x & 0x1 > 0)
				z = (z << 128) / 0x10000000000000000B17217F7D1CF79AB;
				assert(z <= result);
		}
	}

	/// @dev Test for function exp.
	/// @param x signed 64.64-bit fixed point number
	function testExp (int128 x) public view {
		bool precondition = x < 0x400000000000000000;
		bool precondition2 = x < -0x400000000000000000;

		// If precondition is false then we don't want to go down that dead branch.
		if (!precondition) {
			try this.exp(x) { assert(false); } catch {}
		// If precondition2 is true then the result should be 0.
		} else if(precondition2) {
			int128 z = exp(x);
			assert(z == 0);
		} else {
			int128 z = exp(x);
			int128 z2 = exp_2(int128(int256(x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
			assert(z <= z2);
		}
	}
}
