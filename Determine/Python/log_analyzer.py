#!/usr/bin/env python
def parser(filename, top_error):
    with open(filename) as f:
        word = f.read().split()

    counter = {i: word.count(i) for i in set(word)}
    sort = sorted(counter.items(), key=lambda item: item[1], reverse=True)
    print(sort)
    for i in sort[:top_error]:
        print(i[0])


parser('error.log', 10)

