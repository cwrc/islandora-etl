from setuptools import setup

setup(
    name="Islandora7 Export",
    version="0.0.1",
    author="Jeffery Antoniuk",
    author_email="jeffery.antoniuk@ualberta.ca",
    description="A command-line tool that allows Exporting Islandora content.",
    url="https://github.com/cwrc/islandora7_export",
    license="The Unlicense",
    install_requires=['requests>=2.22,<3'],
    python_requires='>=3.6'
)
