function ParFileParser(contents) {
    this.contents = contents;
}

ParFileParser.prototype.get = function(val) {
    return this.contents.match(/[^\r\n]+/g)
        .map(function(line) { return line.trim(); })
        .find(function(line) { return line.lastIndexOf(val, 0) === 0; })
        .split('=')[1]
        .trim();
}
