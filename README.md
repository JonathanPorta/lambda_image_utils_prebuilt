# lambda_image_utils_prebuilt
A prebuilt set of the dependencies needed to run face_recognition in AWS Lambda.

## Usage
`pip install lambda_image_utils_prebuilt`

Then, simply place this as the first import in your lambda function's handler:

`import lambda_image_utils_prebuilt.unpack`

## How it Works
The libs needed for face_recognition are built inside a Docker container that matches the environment in which AWS Lambda code is ran.

Since the dependencies for face_recognition exceed the source code size limit of AWS Lambda functions, we do some ridiculousness to make it work. We zip up the deps and then unzip them at runtime.

The unzipping of these deps at runtime will add overhead to your function's start time. So, please keep that in mind in deciding whether to use this package.

## See it in Action
[Here](https://github.com/JonathanPorta/lambda_face_recognition_example) is an example project that uses this project as one of its dependencies.
