import functools
import time


def benchmark(func):
    @functools.wraps(func)
    def timer(*args,**kwargs):
        t = time.time()
        result = func(*args,**kwargs)
        print('Time of exceting function is: %f' % (time.time()-t))
        return result
    return timer


@benchmark
def parser(filename, top_error):
    with open(filename) as f:
        word = f.read().split()

    counter = {i: word.count(i) for i in set(word)}
    sort = sorted(counter.items(), key=lambda item: item[1], reverse=True)
    for i in sort[:top_error]:
        print(i[0])


parser('error.log', 10)
