# Fuzz tests for the ABDK Math 64.64 library using Echidna
This was my submission to the Secureum CAREX TOB Echidna workshop. Didn't find any artificial issues for the evaluation for this submission was disqualified because the code couldn't compile correctly. I would suggest looking at [BMateo](https://github.com/BMateo/EchidnaWorkshop/blob/main/contracts/Echidna-CAREX.sol) for he found 7/10. Still this may be a good learning source to look at and pick apart so enjoy!

## Before starting

Install Echidna 2.0.1:

* Install/upgrade [slither](https://github.com/crytic/slither): `pip3 install slither-analyzer --upgrade`
* Recommended option: [precompiled binaries](https://github.com/crytic/echidna/releases/tag/v2.0.1) (Linux and MacOS supported). 
* Alternative option: [use docker](https://hub.docker.com/layers/echidna/trailofbits/echidna/v2.0.1/images/sha256-526df14f9a90ba5615816499844263e851d7f34ed241acbdd619eb7aa0bb8556?context=explore).

## The contest

This repository contains everything necessary to test expected properties of the *Math 64.64 library*. Users should complete the `Test` creating functions to test different invariants from different mathematical operations (e.g. add, sub, etc) and adding assertions. The developer marked two functions as `private` instead of `internal` (`sqrtu` and `divuu`) which we are NOT going to directly test. 

A few pointers to start:

0. Read the documentation
1. Think of basic arithmetic properties for every operation
2. Consider when operation should or it should *not* revert
3. Some properties could require to use certain tolerance

To start a Echidna fuzzing campaign use:

```
$ echidna-test Echidna-CAREX.sol --contract Test --test-mode assertion --corpus-dir corpus --seq-len 1 --test-limit 1000000 --config config.yaml --format text
```

The last argument, `--test-limit` should be tweaked according to the time you want to spend in the fuzzing campaign. 
Additionally, from time to time, you should remove the corpus using `rm -Rf corpus`.

The recommended Solidity version for the fuzzing campaign is 0.8.1, however, more recent releases can be used as well.

## Expected Results and Evaluation

User should be able to fully test the *Math 64.64 library*. It is worth mentioning that the code is unmodified and there are no known issues. 
If you find some security or correctness issue in the code do NOT post it in this repository nor upstream, since these are public messages.
Instead, [contact us by email](mailto:gustavo.grieco@trailofbits.com) to confirm the issue and discuss how to proceed.

For Secureum, the resulting properties will be evaluated introducing an artificial bug in the code and running a short fuzzing campaign. 

## Documentation

Before starting, please review the [Echidna README](https://github.com/crytic/echidna#echidna-a-fast-smart-contract-fuzzer-), as well as [the official tutorials](https://github.com/crytic/building-secure-contracts/tree/master/program-analysis/echidna). Additionally, there is specific documentation on the libraries:

### Math 64.64

Library of mathematical functions operating with signed 64.64-bit fixed point
numbers.

\[ [documentation](ABDKMath64x64.md) | [source](ABDKMath64x64.sol) \]

## Copyright

Copyright (c) 2019, [ABDK Consulting](https://abdk.consulting/)

All rights reserved.
