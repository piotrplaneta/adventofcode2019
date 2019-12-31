"""
>>> card_at_position_2020()
77863024474406
"""
from typing import List, Tuple
import re

N_CARDS = 119315717514047
REPEATS = 101741582076661

def card_at_position_2020() -> int:
    offset, increment = calculate_offset_and_increment(input())
    repeated_offset, repeated_increment = apply_repeats(offset, increment)

    return (repeated_offset + 2020 * repeated_increment) % N_CARDS

def calculate_offset_and_increment(operations: List[int]) -> Tuple[int, int]:
    offset, increment = 0, 1

    for operation in operations:
        if re.match(r"deal into new stack", operation):
            increment *= -1
            increment %= N_CARDS

            offset += increment
            offset %= N_CARDS
        elif re.match(r"cut (-?\d+)", operation):
            offset += increment * int(re.match(r"cut (-?\d+)", operation).group(1))
            offset %= N_CARDS
        elif re.match(r"deal with increment (-?\d+)", operation):
            increment *= inverse_in_modulo(int(re.match(r"deal with increment (-?\d+)", operation).group(1)))
            increment %= N_CARDS
        else:
            print("unkown operation")
    return offset, increment

def apply_repeats(offset: int, increment: int) -> Tuple[int, int]:
    repeated_increment = pow(increment, REPEATS, N_CARDS)

    repeated_offset = offset * (1 - repeated_increment) * inverse_in_modulo((1 - increment) % N_CARDS)
    repeated_offset %= N_CARDS

    return repeated_offset, repeated_increment

def inverse_in_modulo(number: int) -> int:
    return pow(number, N_CARDS - 2, N_CARDS)

def input() -> List[str]:
    with open("lib/advent_input", 'r') as f:
        return f.read().splitlines()

if __name__ == "__main__":
    import doctest
    doctest.testmod()