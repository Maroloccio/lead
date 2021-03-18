"""Lead."""

import os
import sys

from typing import Sequence


def main(argv: Sequence[str]) -> int:
    """Main."""
    for i, arg in enumerate(argv):
        print(f"{i}) {arg}")
    return os.EX_OK


if __name__ == "__main__":
    sys.exit(main(sys.argv))
