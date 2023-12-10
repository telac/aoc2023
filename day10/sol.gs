function findS() {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("input");
  var data = sheet.getDataRange().getValues();
  var outputSheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName("outputSheet");
  //outputData(0, 0, data, outputSheet);
  Logger.log(sheet.getDataRange());
  for (var i = 0; i < data.length; i++) {
    if (data[i] === undefined) break
    var rowLength = data[i].length;
    // for some reason appscript doesnt allow data[i].length
    for (var j = 0; j < rowLength; ++j) {
      if (data[i][j] == 'S') {
        outputData(j, i, data, outputSheet);
      }
    }
  }
}

  const DIRECTIONS = {
    UP: [0, -1],
    DOWN: [0, 1],
    RIGHT: [1, 0],
    LEFT: [-1, 0]
  }


function getFirstMatchingNeighbor(x, y, neighbors, data) {
    var dx = x;
    var dy = y;
    for (let i in neighbors) {
      var n = neighbors[i];
      var inBounds = (dy + n[1] < 140 && dy + n[1] >= 0 && dx + n[0] < 140 && dx + n[0] >= 0);
      if (!inBounds) {
        continue;
      }
      var oSymbol = data[dy][dx];
      var nSymbol = data[dy + n[1]][dx + n[0]];
      var allowedSymbols = [];
      switch (oSymbol) {
        case "7":
          allowedSymbols = [""]
      }
      switch (n) {
        case DIRECTIONS.UP:
          if (nSymbol == '|' || nSymbol == 'F' || nSymbol == '7') {
            if (['|', 'J', 'L', 'S',].includes(oSymbol)) return DIRECTIONS.UP;
          }
          break;
        case DIRECTIONS.DOWN:
          if (nSymbol == '|' || nSymbol == 'L' || nSymbol == 'J'){
            if (['7', 'F', '|', 'S'].includes(oSymbol)) return DIRECTIONS.DOWN;
          } 
          break;
        case DIRECTIONS.RIGHT:
          if (nSymbol == '-' || nSymbol == 'J' || nSymbol == '7') {
            if(['-','L','F','S'].includes(oSymbol)) return DIRECTIONS.RIGHT;
          }
          break;
        case DIRECTIONS.LEFT:
          if (nSymbol == '-' || nSymbol == 'L' || nSymbol == 'F') {
            if(['-', 'J', '7'].includes(oSymbol)) return DIRECTIONS.LEFT;
          }
          break;
      }
    }
}

function outputData(x, y, data, output) {
    var cell = output.getRange(y, x);
    cell.setValue(data[y][x]);
    var neighbors = [];
    neighbors.push(DIRECTIONS.UP);
    neighbors.push(DIRECTIONS.DOWN);
    neighbors.push(DIRECTIONS.RIGHT);
    neighbors.push(DIRECTIONS.LEFT);
    // get starting dir
    var startDir = getFirstMatchingNeighbor(x, y, neighbors, data);
    var next = data[y + startDir[1]][x + startDir[0]];
    counter = 0;
    dx = x;
    dy = y;
    while (!(next == "S")) {
      if (counter > 30000) {
        //there might be an infinite loop here
        break;
      }
      neighbors = [];
      counter++;
      var dy = dy + startDir[1];
      var dx = dx + startDir[0];
      var outputCell = output.getRange(dy + 1, dx + 1);
      outputCell.setValue(counter);
      //Logger.log("dx: " + dx + " dy: " + dy + " next " + next + "counter " + counter);
      if (counter % 1000 == 0 ) {
        Logger.log("dx: " + dx + " dy: " + dy + " next " + next + "counter " + counter);
      }
      switch (startDir) {
        case DIRECTIONS.UP:
            neighbors.push(DIRECTIONS.UP);
            neighbors.push(DIRECTIONS.RIGHT);
            neighbors.push(DIRECTIONS.LEFT);
          break;
        case DIRECTIONS.DOWN:
            neighbors.push(DIRECTIONS.DOWN);
            neighbors.push(DIRECTIONS.RIGHT);
            neighbors.push(DIRECTIONS.LEFT);
          break;
        case DIRECTIONS.RIGHT:
            neighbors.push(DIRECTIONS.UP);
            neighbors.push(DIRECTIONS.DOWN);
            neighbors.push(DIRECTIONS.RIGHT);
          break;
        case DIRECTIONS.LEFT:
              neighbors.push(DIRECTIONS.UP);
              neighbors.push(DIRECTIONS.DOWN);
              neighbors.push(DIRECTIONS.LEFT);
          break;
      }
      startDir = getFirstMatchingNeighbor(dx, dy, neighbors, data);
      next = data[dy + startDir[1]][dx + startDir[0]];
    }
}
