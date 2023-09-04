import matplotlib.pyplot as plt
import numpy as np
import time

from scipy import optimize

N = 100000

lvls = np.random.rand(N)
lvls *= 1.5

def myfun(u,lvl):
    return u*np.sin(u) - lvl

def measure(root,niter):
    res = np.empty(niter)
    
    out = np.empty(N)
    for k in range(niter):
        s = time.time()
        for i, lv in enumerate(lvls):
            out[i] = root(myfun,0.,2.,lv,xtol=np.finfo(out.dtype).eps)
        res[k] = time.time() - s
    return res

def fort_vs_scipy():
    res0 = np.loadtxt("results_O0.txt")
    res1 = np.loadtxt("results_O1.txt")
    res2 = np.loadtxt("results_O2.txt")
    res3 = np.loadtxt("results_O3.txt")

    niter = 10

    res_brentq = measure(optimize.brentq,niter)

    results = np.column_stack((res0,res1,res2,res3,res_brentq))

    labels = ["zeroin\n(-O{})".format(i) for i in range(4)]
    labels += ["SciPy\n(brentq)"]

    fig, ax = plt.subplots()

    ax.boxplot(results,sym="",labels=labels)

    ax.set_title("Completion time for N = {} root-finding problems".format(N))
    ax.set_ylabel("Time [s]")
    ax.set_yscale('log')

    fig.savefig("result.png")

    plt.show()

def fort_vs_brentq():

    res0 = np.loadtxt("results_O3_zeroin.txt")
    res1 = np.loadtxt("results_O3_zero.txt")
    res2 = np.loadtxt("results_O3_root.txt")
    res3 = np.loadtxt("results_O3_brentq.txt")

    results = np.column_stack((res0,res1,res2,res3))

    labels = ["zeroin\n(-O3)", 
              "PORT zero\n(-O3)",
              "NAPACK root\n(-O3)",
              "SciPy brentq\n(-O3)"]

    fig, ax = plt.subplots()

    ax.boxplot(results,sym="",labels=labels)

    ax.set_title("Completion time for N = {} root-finding problems".format(N))
    ax.set_ylabel("Time [s]")
    #ax.set_yscale('log')
    ax.set_ylim(0)

    fig.savefig("result2.png")

    plt.show()

if __name__ == '__main__':
    
    #fort_vs_scipy()
    fort_vs_brentq()
