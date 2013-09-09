#!/usr/bin/env python
# encoding: utf-8
import os
import sys


PROJECT_HOME = os.environ.get(
    'PROJECTS',
    os.path.join(os.environ.get('HOME'), 'public')
)


def unremovable_dir(path):
    """unremovable_dir(path) -- Verify if a given path can't be removed from the
    PATH env.

    Takes into consideration all variables that are set in environment.

    Return a boolean.

    -- path: a system path

    """
    # TODO: this should be more generic, to accept any number of environ
    # variables. But for the moment it will serve the purpose of allow that some
    # environment paths be ignore from the removal process.

    ignore_path = lambda e, x: os.environ[e] in x if os.environ.get(e) else False
    rules = (
        lambda x: ignore_path('GOPATH', x),
        lambda x: ignore_path('GOROOT', x),
    )
    for fn in rules:
        if fn(path):
            return True
    else:
        return PROJECT_HOME not in path


def back(path):
    """back(path) -- Get One level up in the tree from the path.

    -- path: a system path

    """
    return os.path.normpath(os.path.join(path, '..'))


def get_bin(path):
    """get_bin(path) -- Get the bin directory for the project.

    -- path: a project path

    """
    found = False
    bindir = ''
    while not found:
        bindir = os.path.join(path, 'node_modules', '.bin')
        found = os.path.exists(bindir) or path == PROJECT_HOME
        path = back(path)
    return bindir


def remove_project_from_path(path):
    """remove_project_from_path(path) -- Remove project from path directive.

    -- path: environment $PATH variable

    """
    return ':'.join([pathname for pathname in path.split(':') \
            if unremovable_dir(pathname)])


def add_project_to_path(project, path, sep=':'):
    """add_project_to_path(project, path, sep) -- Add project path to path
    directive.

    -- project: project pathname
    -- path: environment $PATH variable
    -- sep: separator used in $PATH variable

    """
    if project in path:
        return path
    return '{0}{1}{2}'.format(project, sep, path)



def normalize_path(path):
    """normalize_path(path) -- Normalize path by adding the current working
    directory and stripping led slash.

    -- path: variable passed by the shell script

    """
    if not path.startswith('/'):
        path = os.path.join(os.getcwd(), *path.split(os.path.sep))

    if path.endswith('/'):
        path = path[:-1]

    return path



def main(cwd=None):
    path = remove_project_from_path(os.environ.get('PATH'))

    if PROJECT_HOME not in cwd or cwd == PROJECT_HOME:
        return path

    bindir = get_bin(cwd)

    if not os.path.exists(bindir):
        return path

    return add_project_to_path(bindir, path)


if __name__ == '__main__':
    envpath = os.getcwd()
    sys.stdout.write(main(envpath))
