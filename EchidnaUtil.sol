// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "ABDKMath64x64.sol";

/// @title Echidna-CAREX
/// @author 0xNazgul
/// @notice Boiler Plate for all ABDKMath64x64 functions excluding the ABDKMath64x64 developer marked private functions sqrtu and divuu.
contract TestUtil {
	int128 internal zero = ABDKMath64x64.fromInt(0);
	int128 internal one = ABDKMath64x64.fromInt(1);
  	int128 public constant MIN_64x64 = -0x80000000000000000000000000000000;
  	int128 public constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

	event Value(string, int64);
	function debug(string memory x, int128 y) public {
		emit Value(x, ABDKMath64x64.toInt(y));
	}

	function fromInt(int256 x) public pure returns (int128) {
		return ABDKMath64x64.fromInt(x);
	}

	function toInt(int128 x) public pure returns (int64) {
		return ABDKMath64x64.toInt(x);
	}

	function fromUInt(uint256 x) public pure returns (int128) {
		return ABDKMath64x64.fromUInt(x);
	}

	function toUInt(int128 x) public pure returns (uint64) {
		return ABDKMath64x64.toUInt(x);
	}	

	function from128x128(int256 x) public pure returns (int128) {
		return ABDKMath64x64.from128x128(x);
	}

	function to128x128(int128 x) public pure returns (int256) {
		return ABDKMath64x64.to128x128(x);
	}
		
	function add(int128 x, int128 y) public pure returns (int128) {
		return ABDKMath64x64.add(x, y);
	}

	function sub(int128 x, int128 y) public pure returns (int128) {
		return ABDKMath64x64.sub(x, y);
	}

	function mul(int128 x, int128 y) public pure returns (int128) {
		return ABDKMath64x64.mul(x, y);
	}

	function muli(int128 x, int256 y) public pure returns (int256) {
		return ABDKMath64x64.muli(x, y);
	}

	function mulu(int128 x, uint256 y) public pure returns (uint256) {
		return ABDKMath64x64.mulu(x, y);
	}

	function div(int128 x, int128 y) public pure returns (int128) {
		return ABDKMath64x64.div(x, y);
	}

	function divi(int256 x, int256 y) public pure returns (int128) {
		return ABDKMath64x64.divi(x, y);
	}	

	function divu(uint256 x, uint256 y) public pure returns (int128) {
		return ABDKMath64x64.divu(x, y);
	}	

	function neg(int128 x) public pure returns (int128) {
		return ABDKMath64x64.neg(x);
	}	

	function abs(int128 x) public pure returns (int128) {
		return ABDKMath64x64.abs(x);
	}

	function inv(int128 x) public pure returns (int128) {
		return ABDKMath64x64.inv(x);
	}	

	function avg(int128 x, int128 y) public pure returns (int128) {
		return ABDKMath64x64.avg(x, y);
	}

	function gavg(int128 x, int128 y) public pure returns (int128) {
		return ABDKMath64x64.gavg(x, y);
	}

	function pow(int128 x, uint256 y) public pure returns (int128) {
		return ABDKMath64x64.pow(x, y);
	}

	function sqrt(int128 x) public pure returns (int128) {
		return ABDKMath64x64.sqrt(x);
	}

  	function log_2(int128 x) public pure returns (int128) {	
		return ABDKMath64x64.log_2(x);
	}

  	function ln(int128 x) public pure returns (int128) {	
		return ABDKMath64x64.ln(x);
	}

	function exp_2(int128 x) public pure returns (int128) {
		return ABDKMath64x64.exp_2(x);
	}

	function exp(int128 x) public pure returns (int128) {
		return ABDKMath64x64.exp(x);
	}

	function divuu (uint256 x, uint256 y) public pure returns (uint128) {
		unchecked {
		require (y != 0);

		uint256 result;

		if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
			result = (x << 64) / y;
		else {
			uint256 msb = 192;
			uint256 xc = x >> 192;
			if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
			if (xc >= 0x10000) { xc >>= 16; msb += 16; }
			if (xc >= 0x100) { xc >>= 8; msb += 8; }
			if (xc >= 0x10) { xc >>= 4; msb += 4; }
			if (xc >= 0x4) { xc >>= 2; msb += 2; }
			if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

			result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
			require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

			uint256 hi = result * (y >> 128);
			uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

			uint256 xh = x >> 192;
			uint256 xl = x << 64;

			if (xl < lo) xh -= 1;
			xl -= lo; // We rely on overflow behavior here
			lo = hi << 128;
			if (xl < lo) xh -= 1;
			xl -= lo; // We rely on overflow behavior here

			require (xh == hi >> 128);

			result += xl / y;
		}

		require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
		return uint128 (result);
		}
	}

	function sqrtu (uint256 x) public pure returns (uint128) {
		unchecked {
			if (x == 0) return 0;
			else {
				uint256 xx = x;
				uint256 r = 1;
				if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
				if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
				if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
				if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
				if (xx >= 0x100) { xx >>= 8; r <<= 4; }
				if (xx >= 0x10) { xx >>= 4; r <<= 2; }
				if (xx >= 0x8) { r <<= 1; }
				r = (r + x / r) >> 1;
				r = (r + x / r) >> 1;
				r = (r + x / r) >> 1;
				r = (r + x / r) >> 1;
				r = (r + x / r) >> 1;
				r = (r + x / r) >> 1;
				r = (r + x / r) >> 1; // Seven iterations should be enough
				uint256 r1 = x / r;
				return uint128 (r < r1 ? r : r1);
			}
		}
	}	
}
