"""Exhaustive ideal arithmetic regression. SPDX-License-Identifier: Apache-2.0"""
from itertools import product

# FRAC codes 00, 01 and 10 place the replica 1/2, 1/4 and 3/4 count above T.
# FRAC 11 selects the external VEXT reference and has no internal replica code.
FRAC_QUARTERS = (2, 1, 3)


def check():
    decisions = 0
    reference_quarters = {(t, code): 4 * (4 + t) + n for t in range(8)
                          for code, n in enumerate(FRAC_QUARTERS)}
    for activation, weights in product(range(256), repeat=2):
        k = (activation & weights).bit_count()
        # Charge stored by four high ballast units and the eight programmable branches.
        stored = 16
        for r in range(8):
            if activation & (1 << r) and weights & (1 << r):
                stored += 4
        midpoint = []
        for (threshold, code), ref in reference_quarters.items():
            y = stored > ref
            assert y == (k > threshold), (activation, weights, threshold, code)
            if code == 0:
                midpoint.append(y)
            decisions += 1
        # Count mode: the eight midpoint decisions form a thermometer code whose ones equal k.
        assert midpoint == sorted(midpoint, reverse=True), (activation, weights)
        assert sum(midpoint) == k
    print(f"PASS {decisions:,} ideal decisions, 65,536 exact counts, all thermometer-coded")


if __name__ == "__main__":
    check()
