SYMBOLS = {
   'zero': '0',
   'one': '1',
   'two': '2',
   'three': '3',
   'four': '4',
   'five': '5',
   'six': '6',
   'seven': '7',
   'eight': '8',
   'nine': '9'  
}


def get_lines() -> list[str]:
   with open('input.txt') as f:
       return [line.strip("\n") for line in f.readlines()]


def get_first_numeric_value(line: str) -> int:
   for x in range(0, len(line)):
       if line[x].isdigit():
           return line[x]
       for symbol in SYMBOLS:
           if x + len(symbol) < len(line):
               if line[x:x + len(symbol)] == symbol:
                   return SYMBOLS[symbol]


def get_last_numeric_value(line: str) -> int:
   for x in range(len(line) - 1, -1, -1):
       if line[x].isdigit():
           return line[x]
       for symbol in SYMBOLS:
           if x - len(symbol) >= 0:
               if line[x - len(symbol) + 1:x + 1] == symbol:
                   return SYMBOLS[symbol]


def get_numbers(lines: list[str]) -> list[int]:
   numbers = []
   for line in lines:
       first_num = get_first_numeric_value(line)
       last_num = get_last_numeric_value(line)
       number = str(first_num) + str(last_num)
       numbers.append(int(number))
   return numbers


if __name__ == '__main__':
   line = get_lines()
   numbers = get_numbers(line)
   print(sum(numbers))
