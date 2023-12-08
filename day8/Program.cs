
static string[] GetInput()
{
    string contents = File.ReadAllText("input.txt");
    return contents.Split("\n");
}

static Dictionary<string, string> InputToMap(string[] input)
{
    Dictionary<string, string> addresses = [];
    input.ToList().ForEach(x =>
    {
        var row = x.Split(" = ").ToList();
        if (row.Count == 2)
        {
            addresses.Add(row[0], row[1]);
        }
    });
    return addresses;
}

static int RouteFromAtoB(string[] input, string dest, string src)
{
    var instructions = input[0];
    var addresses = InputToMap(input);

    int counter = 0;
    int instructionLength = instructions.Length;
    int instructionIndex = 0;
    string currentLoc = src;
    while (currentLoc != dest)
    {
        var left = addresses[currentLoc].Split(",")[0].Trim('(').Trim();
        var right = addresses[currentLoc].Split(",")[1].Trim(')').Trim();
        string instruction = instructions[instructionIndex].ToString();
        switch (instruction)
        {
            case "R":
                currentLoc = right;
                break;
            case "L":
                currentLoc = left;
                break;
        }
        counter++;
        instructionIndex = instructionIndex + 1 < instructionLength ? instructionIndex + 1 : 0;
    }
    
    return counter;
}


static List<int> Part2(string[] input, string[] srcs) {
    List<string> currentLocs = [.. srcs];
    var instructions = input[0];
    int instructionLength = instructions.Length;
    var addresses = InputToMap(input);
    var counts = currentLocs.Select(x => {
        int counter = 0;
        int instructionIndex = 0;
        var currentLoc = x;
        while (!currentLoc.EndsWith('Z')) {
            var left = addresses[currentLoc].Split(",")[0].Trim('(').Trim();
            var right = addresses[currentLoc].Split(",")[1].Trim(')').Trim();
            string instruction = instructions[instructionIndex].ToString();
            //Console.WriteLine(instruction);
            switch (instruction)
            {
                case "R":
                    currentLoc = right;
                    break;
                case "L":
                    currentLoc = left;
                    break;
            }
            counter++;
            instructionIndex = instructionIndex + 1 < instructionLength ? instructionIndex + 1 : 0;
        }
        return counter;
    }).ToList();
    return counts;
}

static string[] GetStartLocs(string[] input)
{
    List<string> startLocs = [];
    var res = input.ToList().Where(x => {
        var row = x.Split(" = ").ToList();
        if (row.Count == 2) {
            return row[0][2] == 'A';
        }
        return false;
    })
    .Select(x => x.Split(" = ")[0]).ToArray();
    return res;
}

var input = GetInput();
Console.WriteLine($"part1: {RouteFromAtoB(input, "ZZZ", "AAA")}");
var part2Starts = GetStartLocs(input);
var part2a = Part2(input, part2Starts);
Console.WriteLine($"Take LCM of these");
part2a.ForEach(x => Console.WriteLine(x));