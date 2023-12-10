import fs from 'node:fs';

class Game {
  id: number;
  red: number;
  green: number;
  blue: number;
  constructor(id: number, red: number, blue: number, green:number) {
    this.id = id;
    this.red = red;
    this.blue = blue;
    this.green = green;
  }
}

class SolutionContainer {
  part1: number;
  part2: number;
  constructor(part1: number, part2: number) {
    this.part1 = part1;
    this.part2 = part2;
  }
}

async function getLines(): Promise<string> {
    return new Promise((resolve, reject) => {
          fs.readFile('input.txt', 'utf8', (err: any, data: string) => {
            if (err) {
              reject(err);
            }
            resolve(data);
        })
      });
}

async function getRoundInfo(round: string): Promise<Map<string,number>> {
  return new Promise((resolve, reject) => {
    const map = new Map<string, number>();
    const gems = round.split(",");
    gems.forEach(gem => {
      const amount: number = +gem.split(" ")[1];
      const gemName: string = gem.split(" ")[2];
      map.set(gemName, amount);
    })
    resolve(map);
});
}

async function isValid(game: Game) {
  const reds = 12;
  const greens = 13;
  const blues = 14;
  return new Promise((resolve) => {
      if(game.blue <= blues 
        && game.red <= reds 
        && game.green <= greens) {
        resolve(true);
      }
      resolve(false);
  });
}

async function setMinimums(currentRound: Map<string,number>, map: Map<string,number>): Promise<Map<string, number>> {
  for(let [k,v] of currentRound) {
    if(v > (map.get(k) ?? 0)) {
      map.set(k, v);
    }
  }
  return new Promise((resolve) => {
    resolve(map)
});
}

async function getValidGames(lines: string): Promise<SolutionContainer> {
  var games: number[] = new Array();
    var array = lines.split('\n');
    var minimumSum = 0;
    for (const x of array) {
      const id = +x.split(':')[0].split(" ")[1];
      const rounds = x.split(':')[1].split(";");
      var roundValid = true;
      var minimumCubes = new Map<string, number>();
      for (const round of rounds) {
        const map = await getRoundInfo(round);
        const game: Game = new Game(id, map.get('red') ?? 0, map.get('blue') ?? 0, map.get('green') ?? 0)
        const gameStatus = await isValid(game);
        minimumCubes = await setMinimums(map, minimumCubes);
        if (!gameStatus) {
          roundValid = false;
        }
      }
      minimumSum +=  Array.from(minimumCubes.values()).reduce((a, b) => a * b);
      if (roundValid) {
        games.push(id);
      }
    }
    return new Promise((resolve) => {
      const part1 = games.reduce((partialSum, a) => partialSum + a, 0)
      const solutionContainer = new SolutionContainer(part1, minimumSum)
      resolve(solutionContainer);
});
}

const lines = await getLines();
const solutions = await getValidGames(lines);
console.log(solutions.part1);
console.log(solutions.part2);