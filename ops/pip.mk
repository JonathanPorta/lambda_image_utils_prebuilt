pip_package:
	./env/bin/pip install -r requirements.txt
	./env/bin/python version.py
	./env/bin/python setup.py sdist

pip_release:
	./env/bin/twine upload dist/* --config-file ~/.pypirc

pip_deps:
	./env/bin/pip install -r requirements.txt
