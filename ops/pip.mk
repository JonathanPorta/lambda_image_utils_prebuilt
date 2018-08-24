pip_package:
	python version.py
	python setup.py sdist

pip_release:
	twine upload dist/*

pip_deps:
	pip install -r requirements.txt
