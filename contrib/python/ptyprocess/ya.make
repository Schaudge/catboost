PY23_LIBRARY()



VERSION(0.6.0)

LICENSE(ISC)

NO_LINT()

PY_SRCS(
    TOP_LEVEL
    ptyprocess/__init__.py
    ptyprocess/_fork_pty.py
    ptyprocess/ptyprocess.py
    ptyprocess/util.py
)

END()
