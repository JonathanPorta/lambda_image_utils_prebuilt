# Setup
### Dependencies
```
  yarn add prettier eslint eslint-plugin-react eslint-plugin-react-native eslint-plugin-prettier eslint-config-prettier babel-eslint
```

### package.json
```
"scripts":{
  "test": "./node_modules/.bin/eslint . && node node_modules/jest/bin/jest.js",
  "prettify": "find . -name '*.js' -o -path ./node_modules -prune | xargs ./node_modules/.bin/prettier --write"
...
}
...
"prettier":{
  "semi": false,
  "singleQuote": true
}

```

### .eslintrc.json
```
{
  "extends": "prettier",
  "plugins": [

    "react",
    "react-native", "prettier"
  ],
  "parser": "babel-eslint",
  "rules": {
    "prettier/prettier": "error"
  },
  "env": {
    "browser": true,
    "node": true,
    "jest": true
  },
  "ecmaFeatures": {
    "jsx": true
  }
}
```
### .eslintignore
```
  cp ./.gitignore ./.eslintignore
```

# Use It
### 1. Test Run
```
  ./node_modules/.bin/eslint .
```

If the test run looks ok, then commit the changes thus far (just adding eslint/prettier) before moving onto the next step where we will actually run prettier.

### 2. Edit in Place
```
  yarn run prettify
```
