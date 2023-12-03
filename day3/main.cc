#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include <ctype.h> 
#include <unordered_map>


using std::vector;
using std::string;

vector<string> getLines() {
    string line;
    std::ifstream file("input.txt");
    vector<string> vec;
    if (file.is_open()) {
        while (getline(file, line)) {
            vec.push_back(line);
        }
        file.close();
    }
    return vec;

}

struct part {
    int x;
    int y;
    char name;

      bool operator==(const part &other) const
        { return (x == other.x
                    && y == other.y
                    && name == other.name);
        }

};

template <>
struct std::hash<part>
{
    std::size_t operator()( const part& k ) const
    {
        // Compute individual hash values for first, second and third
        // http://stackoverflow.com/a/1646913/126995
        std::size_t res = 17;
        res = res * 31 + hash<int>()( k.x );
        res = res * 31 + hash<int>()( k.y );
        res = res * 31 + hash<char>()( k.name );
        return res;
    }
};



struct neigbhor {
    bool hasNeighbor;
    part neighborType;
};

bool isSymbol(char c) {
    if (c == '.') {
        return false;
    }
    if (isdigit(c)) {
        return false;
    }
    return true;
}


neigbhor hasSymbolNeighbor(vector<string> lines, int xStart, int xEnd, int y, int nx, int ny) {
    for (int i = -1; i <= 1; ++i) {
        for (int j = -1; j <= 1; ++j) {
            for (int v = xStart; v <= xEnd; ++v) {
                if (v + j < nx && v + j > 0
                    && y + i < ny && y + i > 0) {
                        char c = lines[y + i][v + j];
                        if (isSymbol(c)) {
                            neigbhor n = {};
                            part p = {};
                            p.name = c;
                            p.x = v + j;
                            p.y = y + i;
                            n.hasNeighbor = true;
                            n.neighborType = p;
                            return n;
                        }
                }
            } 
        }
    }
    neigbhor n = {};
    n.hasNeighbor = false;
    return n;
}

int incrementSum(vector<string> lines,
        std::stringstream& currentNum,
        int j,
        int i,
        int currentLength,
        int nx,
        int ny,
        std::unordered_map<part, vector<int> >& partMap) {
    int num = 0;
    neigbhor neighborInfo = hasSymbolNeighbor(lines, j - currentLength, j - 1, i, nx, ny);
    if(neighborInfo.hasNeighbor) {
        currentNum >> num;
        if (!partMap.contains(neighborInfo.neighborType)) {
            vector<int> parts;
            parts.push_back(num);
            partMap[neighborInfo.neighborType] = parts;
        } else {
            partMap[neighborInfo.neighborType].push_back(num);
        }
    }
    // reset string stream
    return num;
}

int getSum(vector<string> lines, int nx, int ny) {
    int sum = 0;
    std::unordered_map<part, vector<int> > partMap; 
    for (int i = 0; i < ny; ++i) {
        std::stringstream currentNum;
        int currentLength = 0;
        for (int j = 0; j < nx; ++j) {
            char currentChar = lines[i][j];
            if (isdigit(currentChar)) {
                currentNum << currentChar;
                currentLength++;
                if (j == nx - 1) {
                    // special case, end of line j + 1 as the function assumes we're one step ahead of the string
                    sum += incrementSum(lines, currentNum, j + 1, i, currentLength, nx, ny, partMap);
                    currentNum.str(std::string());
                    currentNum.clear();
                    currentLength = 0;
                }
            } else {
                if (currentLength == 0) {
                    continue;
                } else {
                    sum += incrementSum(lines, currentNum, j, i, currentLength, nx, ny, partMap);
                    currentNum.str(std::string());
                    currentNum.clear();
                    currentLength = 0;
                }
            }
        }
    }
    int gearRatio = 0;
    for (auto& [key, value] : partMap) {
        if (key.name == '*' && value.size() == 2) {
            gearRatio += value[0] * value[1];
        } 
    }
    std::cout << "part 2: " << gearRatio << std::endl;
    return sum;
}

int main() {
    vector<string> lines = getLines();
    int nx = lines[0].length();
    int ny = lines.size();
    std::cout << nx << " " << ny;
    int part1 = getSum(lines, nx, ny);
    std::cout << "\n" << "part1 " << part1 << std::endl; 
    return 0;
}
