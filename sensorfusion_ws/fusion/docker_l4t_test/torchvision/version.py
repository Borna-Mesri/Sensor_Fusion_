__version__ = '0.16.0+fbb4cc5'
git_version = 'fbb4cc54ed521ba912f50f180dc16a213775bf5c'
from torchvision.extension import _check_cuda_version
if _check_cuda_version() > 0:
    cuda = _check_cuda_version()
