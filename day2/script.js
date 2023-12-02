const fs = require('node:fs');

function getLines() {

    return new Promise((resolve, reject) => {
          fs.readFile('input.txt', 'utf8', (err, data) => {
            if (err) {
              reject(err);
            }
            resolve(data);
        })
      });
}

function iterateLines(lines) {
  var array = lines.split('\n');
  array.forEach(x => {
    console.log("we iterating");
    console.log(x);
  });
}

data = getLines().then(data => {
  iterateLines(data);
}
  ).catch(err =>  {
    console.log(err)
  })