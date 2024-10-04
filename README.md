# ARCollab

Collaborative, multi-user cardiovascular surgical planning in mobile Augmented Reality.

[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)
[![arxiv badge](https://img.shields.io/badge/arXiv-2408.03249-red)](https://arxiv.org/pdf/2408.03249)

![Screenshot 2024-05-01 at 2 15 02 PM](https://github.com/poloclub/arcollab/assets/23846495/6d86bd26-870d-4d69-85b9-b28523875e3b)

## What is ARCollab?

ARCollab is a collaborative cardiovascular surgical planning application in mobile augmented reality. Multiple users can join a shared session and view the a patient’s 3D heart model from different perspectives. It allows surgeons and cardiologists to collaboratively interact with a 3D heart model in real-time, perform transformations and omni-directional slicing. Changes made on a device update the model’s orientation on the other devices in the session.

Collaborative planning for congenital heart diseases typically involves creating physical heart models through 3D printing, which are then examined by both surgeons and cardiologists. Recent developments in mobile augmented reality (AR) technologies have presented a viable alternative, known for their ease of use and portability. However, there is still a lack of research examining the utilization of multi-user mobile AR environments to support collaborative planning for cardiovascular surgeries. We created ARCollab, an iOS AR app designed for enabling multiple surgeons and cardiologists to interact with a patient’s 3D heart model in a shared environment. ARCollab enables surgeons and car- diologists to import heart models, manipulate them through gestures and collaborate with other users, eliminating the need for fabricating physical heart models. Our evaluation of ARCollab’s usability and usefulness in enhancing collaboration, conducted with three cardiothoracic surgeons and two cardiologists, marks the first human evaluation of a multi-user mobile AR tool for surgical planning.

## Getting Started

ARCollab supports both single-user and multi-user sessions. It is simple to start a session:

### Starting a session & importing a model

1. Open the app and enter your name when prompted.
2. Select ‘Continue’ to see the list of available nearby devices. Tap on devices you would like to connect with and select ‘Begin Session’. If you would like to start a single-user session, select ‘Begin Session’ directly.
3. Load a model using the ‘import’ button at the lower-left. Then scan the environment and tap on the screen to place the model in front of you. All other devices immediately receive the model.

### Control the heart’s orientation and perform omni-directional slicing

Control the mode using the control at the bottom-right. Choose ‘View’ to control the heart’s orientation and scale, and ’Slice’ to perform omni-directional slicing.

In view mode, you can use the following gestures:
- **Rotation** to twist
- **Pinch** to scale
- **Pan** to rotate

![model transform](https://github.com/poloclub/arcollab/assets/23846495/31dde993-3141-4e88-b00c-12b844b0b836)

In slice mode, you can use the following gestures:
    - **Rotation** to twist
    - **Pinch** to translate
    - **Pan** to rotate

![slicing](https://github.com/poloclub/arcollab/assets/23846495/00d4c931-a54a-489e-b20a-c97612b05cc8)

### Save and load the model

Use the ’save’ button at the top-right to save your model’s current orientation properties, and load it back later.

![save_load](https://github.com/poloclub/arcollab/assets/23846495/c0738de9-574d-4151-8eb6-9c3246c6d342)

## Credits

ARCollab is created by Pratham Mehta, Rahul Narayanan, Harsha Karanth, and Polo Chau.

## License

The software is available under the MIT License.
