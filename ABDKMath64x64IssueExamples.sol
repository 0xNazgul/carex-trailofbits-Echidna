pragma solidity ^0.8.0;


library ABDKMath64x64IssueExamples {

    int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;


    int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    // Easy to catch
    function add(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) + y + 1; // changed line
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    // Easy to catch
    function add(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            int256 result = int256(x) + y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return neg(int128(result)); // changed line
        }
    }

    // Medium to catch
    function div(int128 x, int128 y) internal pure returns (int128) {
        unchecked {
            require(y != 0);
            if (y < fromInt(1)) { // changed line
                return fromInt(-1); // changed line
            } 
            int256 result = (int256(x) << 64) / y;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128(result);
        }
    }

    // Medium to catch
    function inv(int128 x) internal pure returns (int128) {
        unchecked {
            require(x != 0);
            int256 result = int256 (0x100000000000000000000000000000000) / x;
            require(result >= MIN_64x64 && result <= MAX_64x64);
            return int128 (2 * result); // changed line
        }
    }

    // Hard to catch
    function muli(int128 x, int256 y) internal pure return (int256) {
        unchecked {
            if (x == MIN_64x64) {
                require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
                    y <= 0x1000000000000000000000000000000000000000000000000);
                return -y << 63;
            } else {
                bool negativeResult = false;
                if (x < 0) {
                    // x = -x; changed line (it got commented out)
                    negativeResult = true;
                }
                if (y < 0) {
                    y = -y; 
                    negativeResult = !negativeResult;
                }
                uint256 absoluteResult = mulu (x, uint256 (y));
                if (negativeResult) {
                    require (absoluteResult <=
                        0x8000000000000000000000000000000000000000000000000000000000000000);
                    return -int256 (absoluteResult); 
                } else {
                    require (absoluteResult <=
                        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
                    return int256 (absoluteResult);
                }
            }
        }
    }

    // Hard to catch
    function abs(int128 x) internal pure return (int128) {
        unchecked {
            // require (x != MIN_64x64); changed line (it got commented out)
            return x < 0 ? -x : x;
        }
    }
}