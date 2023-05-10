const fs = require('fs');

const fileBytes = [];
for (let i = 255 ; i >= 1; i -= 1) {
    fileBytes.push(i);
}

fs.writeFileSync('numbers.bin', Buffer.from(fileBytes));
