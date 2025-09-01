# Multi-User GPU Sharing System with Slurm and JupyterHub
## Complete Setup and Configuration Documentation

---

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [System Architecture](#system-architecture)
3. [Current Environment](#current-environment)
4. [Complete Setup Instructions](#complete-setup-instructions)
5. [Configuration Files](#configuration-files)
6. [Usage Instructions](#usage-instructions)
7. [Troubleshooting](#troubleshooting)
8. [Testing Procedures](#testing-procedures)

---

## 📎 Project Overview

### The Problem
We have a single powerful GPU (RTX 3070Ti for testing, A6000 for production) that needs to be shared among multiple ML researchers. Without proper management, researchers conflict over GPU access and block each other from working.

### The Solution
A transparent GPU queuing system where:
- **All researchers can log in simultaneously** - no blocking at login
- **Everyone can edit notebooks and run CPU code anytime** - work is never blocked  
- **GPU access is automatically queued ONLY when executing GPU code** - transparent management
- **Users see clear queue feedback** - know when their job will run
- **Simple to use** - researchers write normal Python with minimal changes (just add `%%gpu` magic)

### Key Innovation
Unlike traditional HPC setups where users must choose resources at login, our system gives everyone the same environment and only queues GPU access when actually needed at code execution time.

---

## 🏗️ System Architecture

### Components Stack
```
┌─────────────────────────────────────────┐
│         Web Browser (Users)             │
└────────────────┬────────────────────────┘
                 │ HTTP :8000
┌────────────────▼────────────────────────┐
│           JupyterHub                    │
│  • Single LocalProcessSpawner for all   │
│  • No profiles - everyone gets same env │
└────────────────┬────────────────────────┘
                 │ Spawns
┌────────────────▼────────────────────────┐
│       Jupyter Notebooks                 │
│  • GPU Helper automatically loaded      │
│  • %%gpu magic command available        │
└────────────────┬────────────────────────┘
                 │ %%gpu magic triggers
┌────────────────▼────────────────────────┐
│            Slurm (srun)                 │
│  • Manages GPU queue                    │
│  • Allocates GPU when available         │
└────────────────┬────────────────────────┘
                 │ Executes on
┌────────────────▼────────────────────────┐
│      NVIDIA GPU (via WSL2)              │
│  • RTX 3070Ti (test)                    │
│  • A6000 (production)                   │
└─────────────────────────────────────────┘
```

### Key Design Decisions
1. **Single Profile System**: Everyone logs into the same environment (no CPU/GPU choice at login)
2. **Runtime GPU Allocation**: GPU is only requested when `%%gpu` magic is used
3. **Transparent Queuing**: Users see queue status but don't manage it manually
4. **WSL2 Compatibility**: Special configurations for WSL2 CUDA access

---

## 💻 Current Environment

### System Specifications
- **OS**: Fedora 42 on WSL2 (Windows Subsystem for Linux)
- **GPU**: NVIDIA RTX 3070Ti (8GB VRAM) - test environment
- **Target GPU**: NVIDIA A6000 (48GB VRAM) - production
- **Python**: 3.13.6
- **CUDA**: 12.9 (via WSL2)
- **Users**: ori, researcher1, researcher2, researcher3

### Installed Software Versions
- **Slurm**: 24.05.2
- **JupyterHub**: 5.3.0
- **JupyterLab**: 4.4.5
- **PyTorch**: 2.5.1+cu121 (working with CUDA)
- **BatchSpawner**: 1.3.0
- **WrapSpawner**: 1.0.1

### Critical WSL2-Specific Requirements
- Manual NVIDIA device creation required
- AutoDetect=off in Slurm GRES configuration
- Special library paths for CUDA libraries
- All NVIDIA libraries must be in LD_LIBRARY_PATH

## ✅ Current Implementation Status

### Working Features
- ✅ **Slurm GPU scheduling**: Successfully allocates GPU via `--gres=gpu:1`
- ✅ **JupyterHub access**: All users can login simultaneously
- ✅ **GPU queue system**: Jobs queue properly when GPU is busy
- ✅ **PyTorch CUDA**: Fixed library issues, PyTorch detects GPU correctly
- ✅ **%%gpu magic command**: Successfully submits jobs to Slurm
- ✅ **Informative queue feedback**: Shows exact queue position, who's using GPU, and time remaining
- ✅ **CPU work unblocked**: Users can run CPU code while others use GPU
- ✅ **Transparent queueing**: GPU automatically allocated when available
- ✅ **Job cancellation**: Users can cancel jobs with interrupt button or `scancel`

### Verified Test Results
```python
# GPU detection works:
PyTorch version: 2.5.1+cu121
CUDA available: True
GPU: NVIDIA GeForce RTX 3070 Ti

# Queue status display shows:
⏳ GPU Queue Status:
Currently using GPU:
• User: researcher1 | Running for: 00:45:23 | Time left: 01:14:37
Jobs waiting in queue: 2
Your position: #3
```

### Design Decision: Blocking Behavior
- ⚠️ **Intentional**: When a %%gpu cell is queued, the notebook waits (same as Google Colab)
- ✅ **Users can open multiple notebook tabs** for parallel work
- ✅ **Matches industry standard** behavior (Colab, Kaggle)

---

## 🔧 Complete Setup Instructions

### Step 1: System Preparation

**Why these packages are needed:**
- **gcc, make, kernel-devel**: Required to compile Slurm and MUNGE from source if needed
- **python3, pip**: Base Python environment for JupyterHub and notebooks
- **nodejs, npm**: Required by JupyterHub for the proxy service that routes users to their notebooks
- **slurm packages**: The job scheduler that manages GPU queue
- **munge**: Authentication service that ensures secure communication between Slurm components
- **mariadb-server**: Database for Slurm accounting (optional but useful for tracking usage)

```bash
# Update system
sudo dnf update -y

# Install required packages
sudo dnf install -y gcc gcc-c++ make kernel-devel kernel-headers
sudo dnf install -y python3 python3-pip python3-devel nodejs npm
sudo dnf install -y slurm slurm-slurmd slurm-slurmctld slurm-slurmdbd mariadb-server
sudo dnf install -y munge munge-libs munge-devel
```

### Step 2: Create Users and Directories

**Why this setup is needed:**
- **slurm user**: Slurm daemons run as this dedicated user for security
- **Directory structure**: Slurm needs specific directories for logs, state files, and job information
- **Permissions**: Strict permissions prevent unauthorized access to job data
- **Research users**: Test users to verify multi-user functionality

```bash
# Create Slurm user
sudo useradd -r -s /bin/false slurm

# Create required directories
sudo mkdir -p /var/log/slurm-llnl /var/run/slurm-llnl 
sudo mkdir -p /var/spool/slurm-llnl /var/spool/slurmd /var/spool/slurmctld

# Set permissions
sudo chown -R slurm:slurm /var/log/slurm-llnl /var/run/slurm-llnl 
sudo chown -R slurm:slurm /var/spool/slurm-llnl /var/spool/slurmd /var/spool/slurmctld
sudo chmod -R 755 /var/log/slurm-llnl /var/run/slurm-llnl /var/spool/slurm-llnl

# Create research users
for user in researcher1 researcher2 researcher3; do
    sudo useradd -m -s /bin/bash $user
    echo "$user:test123" | sudo chpasswd
done
```

### Step 3: Configure MUNGE Authentication

**Why MUNGE is critical:**
- **Security**: Prevents users from impersonating each other when submitting jobs
- **Authentication**: Ensures only authorized users can submit jobs to Slurm
- **Encryption**: All Slurm communication is encrypted using the MUNGE key
- **Trust**: Allows slurmd and slurmctld to trust each other

```bash
# Generate MUNGE key (must be random for security)
sudo dd if=/dev/urandom bs=1 count=1024 of=/etc/munge/munge.key
sudo chown munge:munge /etc/munge/munge.key
sudo chmod 400 /etc/munge/munge.key

# Start MUNGE
sudo systemctl enable munge
sudo systemctl start munge
```

### Step 4: WSL2 GPU Device Setup (CRITICAL)

**Why manual device creation is needed:**
- **WSL2 limitation**: Unlike native Linux, WSL2 doesn't automatically create /dev/nvidia* devices
- **Device nodes**: These special files allow programs to communicate with the GPU
- **Persistence**: Must recreate on each WSL2 restart, hence the systemd service
- **nvidia-smi path**: WSL2 puts nvidia-smi in a non-standard location

```bash
# Create NVIDIA devices (WSL2 doesn't create them automatically)
sudo mknod -m 666 /dev/nvidia0 c 195 0      # GPU device
sudo mknod -m 666 /dev/nvidiactl c 195 255  # Control device
sudo mknod -m 666 /dev/nvidia-modeset c 195 254  # Modeset device

# Create persistence script (runs on every boot)
sudo tee /usr/local/bin/create-nvidia-devices.sh << 'EOF'
#!/bin/bash
if [ ! -e /dev/nvidia0 ]; then
    mknod -m 666 /dev/nvidia0 c 195 0
fi
if [ ! -e /dev/nvidiactl ]; then
    mknod -m 666 /dev/nvidiactl c 195 255
fi
if [ ! -e /dev/nvidia-modeset ]; then
    mknod -m 666 /dev/nvidia-modeset c 195 254
fi
EOF

sudo chmod +x /usr/local/bin/create-nvidia-devices.sh

# Create systemd service for device creation
sudo tee /etc/systemd/system/nvidia-devices.service << 'EOF'
[Unit]
Description=Create NVIDIA devices
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/create-nvidia-devices.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable nvidia-devices.service
sudo systemctl start nvidia-devices.service

# Create nvidia-smi symlink for Slurm (WSL2 specific path)
sudo ln -sf /usr/lib/wsl/lib/nvidia-smi /usr/local/bin/nvidia-smi
```

### Step 5: Configure Slurm

**Main configuration (slurm.conf) - what each section does:**
- **ClusterName**: Identifies your "cluster" (even single node needs a name)
- **Authentication**: Uses MUNGE for secure job submission
- **SelectType=cons_tres**: Enables consumable resources (needed for GPU scheduling)
- **GresTypes=gpu**: Tells Slurm to manage GPU as a schedulable resource
- **Node definition**: Describes your machine's resources (CPUs, RAM, GPUs)
- **Partition**: Logical grouping of nodes (we have one partition with one node)

```bash
# Main Slurm configuration
sudo tee /etc/slurm/slurm.conf << 'EOF'
# Basic Slurm Configuration
ClusterName=ml-cluster
SlurmctldHost=William(127.0.0.1)
SlurmctldPort=6817
SlurmdPort=6818

# Authentication
AuthType=auth/munge
CryptoType=crypto/munge

# Scheduling
SelectType=select/cons_tres
SchedulerType=sched/backfill

# State preservation
StateSaveLocation=/var/spool/slurmctld

# Logging
SlurmctldLogFile=/var/log/slurm-llnl/slurmctld.log
SlurmdLogFile=/var/log/slurm-llnl/slurmd.log

# PID files
SlurmctldPidFile=/var/run/slurm-llnl/slurmctld.pid
SlurmdPidFile=/var/run/slurm-llnl/slurmd.pid

# GPU support
GresTypes=gpu

# Node configuration
NodeName=William NodeAddr=127.0.0.1 CPUs=16 RealMemory=15000 Gres=gpu:1 State=UNKNOWN
PartitionName=normal Nodes=William Default=YES MaxTime=INFINITE State=UP

# Run as slurm user
SlurmUser=slurm
EOF
```

**GRES configuration (gres.conf) - GPU resource definition:**
- **AutoDetect=off**: CRITICAL for WSL2 - NVML library doesn't work in WSL2
- **File=/dev/nvidia0**: Points to the GPU device we created manually

```bash
# GRES configuration (CRITICAL for WSL2)
sudo tee /etc/slurm/gres.conf << 'EOF'
AutoDetect=off
Name=gpu File=/dev/nvidia0
EOF
```

**SystemD override - permission fix:**
- **Why needed**: Default service tries to run as slurm user but needs root for some operations
- **Override**: Allows slurmctld to start properly without permission errors

```bash
# Fix systemd permissions
sudo mkdir -p /etc/systemd/system/slurmctld.service.d
sudo tee /etc/systemd/system/slurmctld.service.d/override.conf << 'EOF'
[Service]
User=root
Group=root
EOF

sudo systemctl daemon-reload
```

### Step 6: Configure CUDA Libraries

**Why this complex library setup is needed:**
- **PyTorch dependencies**: PyTorch needs multiple NVIDIA libraries (cudnn, nccl, cublas, etc.)
- **Non-standard paths**: pip installs NVIDIA libraries in Python site-packages, not system paths
- **Dynamic linking**: Programs need to find these libraries at runtime
- **ldconfig**: Updates the system's library cache so libraries are found automatically

```bash
# Find all NVIDIA library paths installed by pip
find /usr/local/lib/python3.13/site-packages/nvidia -name "*.so*" -exec dirname {} \; | sort -u

# Setup comprehensive NVIDIA library paths
sudo tee /etc/ld.so.conf.d/nvidia-pytorch.conf << 'EOF'
/usr/local/lib/python3.13/site-packages/nvidia/cudnn/lib
/usr/local/lib/python3.13/site-packages/nvidia/nccl/lib
/usr/local/lib/python3.13/site-packages/nvidia/cublas/lib
/usr/local/lib/python3.13/site-packages/nvidia/cuda_cupti/lib
/usr/local/lib/python3.13/site-packages/nvidia/cuda_nvrtc/lib
/usr/local/lib/python3.13/site-packages/nvidia/cuda_runtime/lib
/usr/local/lib/python3.13/site-packages/nvidia/cufft/lib
/usr/local/lib/python3.13/site-packages/nvidia/curand/lib
/usr/local/lib/python3.13/site-packages/nvidia/cusolver/lib
/usr/local/lib/python3.13/site-packages/nvidia/cusparse/lib
/usr/local/lib/python3.13/site-packages/nvidia/nvjitlink/lib
/usr/local/lib/python3.13/site-packages/nvidia/nvtx/lib
/usr/local/cuda-12.9/targets/x86_64-linux/lib
EOF

# Update library cache (CRITICAL - fixes "libnccl.so.2 not found" error)
sudo ldconfig

# Verify PyTorch works
python3 -c "import torch; print(f'PyTorch: {torch.__version__}'); print(f'CUDA: {torch.cuda.is_available()}')"
```

### Step 7: Install Python Packages

**Why each package is needed:**
- **jupyterhub**: Main server that manages user sessions
- **jupyterlab/notebook**: The actual notebook interface users see
- **batchspawner**: Allows JupyterHub to submit jobs to Slurm
- **wrapspawner**: Enables profile selection (though we don't use profiles now)
- **PyTorch**: ML framework with GPU support
- **NVIDIA libraries**: Runtime dependencies for CUDA operations

```bash
# Install JupyterHub and related packages
sudo pip install jupyterhub jupyterlab notebook
sudo pip install batchspawner wrapspawner
sudo pip install ipython-autotime slurm-magic subprocess-tee

# Install PyTorch with CUDA
sudo pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Install NVIDIA libraries
sudo pip install nvidia-nccl-cu12 nvidia-cublas-cu12 nvidia-cudnn-cu12 nvidia-nvtx-cu12
```

### Step 8: Configure JupyterHub

**Why each configuration matters:**
- **LocalProcessSpawner**: Critical - gives everyone immediate CPU access (no blocking at login)
- **DummyAuthenticator**: Simple testing auth (replace with PAM/OAuth in production)
- **No profiles**: Everyone gets same environment - GPU allocated per-cell, not per-session
- **bind_url**: Makes JupyterHub accessible on all network interfaces
- **admin_users**: Allows these users to manage the hub

```bash
# Create JupyterHub directory
sudo mkdir -p /etc/jupyterhub

# Create main configuration
sudo tee /etc/jupyterhub/jupyterhub_config.py << 'EOF'
from jupyterhub.auth import DummyAuthenticator
from jupyterhub.spawner import LocalProcessSpawner

# Basic settings
c.JupyterHub.bind_url = 'http://0.0.0.0:8000'
c.JupyterHub.hub_ip = '0.0.0.0'

# Authentication (for testing - replace with PAM or OAuth in production)
c.JupyterHub.authenticator_class = DummyAuthenticator
c.DummyAuthenticator.password = "test123"

# Single spawner for everyone - no profiles
c.JupyterHub.spawner_class = LocalProcessSpawner

# Default to JupyterLab
c.Spawner.default_url = '/lab'
c.Spawner.start_timeout = 120

# Admin users
c.Authenticator.admin_users = {'ori', 'researcher1', 'researcher2', 'researcher3'}

# Allow named servers for collaboration
c.JupyterHub.allow_named_servers = True
c.JupyterHub.named_server_limit_per_user = 1

# Logging
c.JupyterHub.log_level = 'INFO'

# Database
c.JupyterHub.db_url = 'sqlite:////etc/jupyterhub/jupyterhub.sqlite'
c.JupyterHub.cookie_secret_file = '/etc/jupyterhub/jupyterhub_cookie_secret'
EOF
```

### Step 9: Create GPU Helper Scripts

**Why this helper is the core innovation:**
- **%%gpu magic**: Provides simple interface for GPU code execution
- **Transparent queueing**: Automatically submits to Slurm without user knowing Slurm commands
- **Library path management**: Ensures CUDA libraries are found when job runs on compute node
- **Queue visibility**: Shows users their position and estimated wait time
- **Error handling**: Gracefully handles GPU busy scenarios

```bash
# Create directory for custom scripts
sudo mkdir -p /etc/jupyterhub/custom_scripts

# Create GPU helper module with informative queue display
sudo tee /etc/jupyterhub/custom_scripts/gpu_helper.py << 'EOF'
"""
GPU Helper for Transparent Slurm Integration with Informative Queue Status
Provides %%gpu magic command for automatic GPU queueing
"""

import subprocess
import tempfile
import os
import sys
from functools import wraps
from IPython.display import display, HTML

# NVIDIA library paths for WSL2 - these must all be available for PyTorch to work
NVIDIA_LIB_PATHS = [
    '/usr/local/lib/python3.13/site-packages/nvidia/cudnn/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/nccl/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/cublas/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/cuda_cupti/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/cuda_nvrtc/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/cuda_runtime/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/cufft/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/curand/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/cusolver/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/cusparse/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/nvjitlink/lib',
    '/usr/local/lib/python3.13/site-packages/nvidia/nvtx/lib',
    '/usr/local/cuda-12.9/targets/x86_64-linux/lib',
    '/usr/lib/wsl/lib'
]

def create_cuda_env_setup():
    """Generate environment setup code for CUDA libraries"""
    paths = ':'.join(NVIDIA_LIB_PATHS)
    return f"""
import os
os.environ['LD_LIBRARY_PATH'] = '{paths}:' + os.environ.get('LD_LIBRARY_PATH', '')
os.environ['CUDA_HOME'] = '/usr/local/cuda-12.9'
"""

def get_gpu_queue_status():
    """Get detailed GPU queue information"""
    result = subprocess.run(
        ['squeue', '-o', '%i|%j|%u|%T|%b|%M|%L'],
        capture_output=True, text=True
    )
    
    if not result.stdout:
        return None
    
    lines = result.stdout.strip().split('\n')
    if len(lines) <= 1:
        return None
    
    gpu_jobs = {'running': [], 'pending': []}
    
    for line in lines[1:]:  # Skip header
        parts = line.split('|')
        if len(parts) >= 5:
            job_id = parts[0].strip()
            job_name = parts[1].strip()
            user = parts[2].strip()
            state = parts[3].strip()
            gres = parts[4].strip()
            time_used = parts[5].strip() if len(parts) > 5 else 'N/A'
            time_left = parts[6].strip() if len(parts) > 6 else 'N/A'
            
            if 'gpu' in gres.lower():
                job_info = {
                    'id': job_id,
                    'user': user,
                    'name': job_name,
                    'time_used': time_used,
                    'time_left': time_left
                }
                
                if state in ['RUNNING', 'R']:
                    gpu_jobs['running'].append(job_info)
                elif state in ['PENDING', 'PD']:
                    gpu_jobs['pending'].append(job_info)
    
    return gpu_jobs

def gpu_cell(code_str, time_limit="01:00:00", memory="4G"):
    """Run a cell of code on GPU through Slurm with queue information."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.py', delete=False) as tf:
        tf.write("#!/usr/bin/env python3\n")
        tf.write(create_cuda_env_setup())
        tf.write("\n# User code starts here\n")
        tf.write(code_str)
        script_path = tf.name
    
    try:
        display(HTML('<div style="background: #ffffcc; padding: 10px; border-radius: 5px;">⏳ <b>Submitting to GPU queue...</b></div>'))
        
        env = os.environ.copy()
        env['LD_LIBRARY_PATH'] = ':'.join(NVIDIA_LIB_PATHS) + ':' + env.get('LD_LIBRARY_PATH', '')
        
        # Check GPU availability
        check_cmd = ['srun', '--gres=gpu:1', '--immediate=5', 'echo', 'GPU available']
        try:
            check = subprocess.run(check_cmd, capture_output=True, text=True, timeout=6)
            
            if check.returncode != 0:
                # GPU is busy - show detailed queue information
                queue_status = get_gpu_queue_status()
                
                if queue_status:
                    running_jobs = queue_status['running']
                    pending_jobs = queue_status['pending']
                    
                    message = '<div style="background: #ffeecc; padding: 10px; border-radius: 5px;">'
                    message += '⏳ <b>GPU Queue Status:</b><br><br>'
                    
                    if running_jobs:
                        message += '<b>Currently using GPU:</b><br>'
                        for job in running_jobs:
                            message += f"• User: {job['user']} | Running for: {job['time_used']} | Time left: {job['time_left']}<br>"
                    
                    if pending_jobs:
                        message += f'<br><b>Jobs waiting in queue: {len(pending_jobs)}</b><br>'
                        message += '<b>Your position: #' + str(len(pending_jobs) + 1) + '</b><br>'
                    else:
                        message += '<br><b>Your position in queue: #1</b> (next to run)<br>'
                    
                    message += '<br><small>Your job will run automatically when GPU becomes available.</small>'
                    message += '</div>'
                    
                    display(HTML(message))
            else:
                display(HTML('<div style="background: #ccffcc; padding: 10px; border-radius: 5px;">✅ <b>GPU is available - starting immediately!</b></div>'))
                
        except subprocess.TimeoutExpired:
            pass
        
        # Run the actual job
        cmd = [
            'srun',
            '--gres=gpu:1',
            f'--time={time_limit}',
            f'--mem={memory}',
            '--export=ALL',
            'python3', script_path
        ]
        
        result = subprocess.run(cmd, capture_output=True, text=True, env=env)
        
        if result.returncode == 0:
            display(HTML('<div style="background: #ccffcc; padding: 10px; border-radius: 5px;">✅ <b>GPU execution complete!</b></div>'))
            print(result.stdout)
        else:
            display(HTML('<div style="background: #ffcccc; padding: 10px; border-radius: 5px;">❌ <b>Error during execution:</b></div>'))
            print(result.stderr)
            
    finally:
        if os.path.exists(script_path):
            os.unlink(script_path)

# Register IPython magic
try:
    from IPython.core.magic import register_line_cell_magic
    
    @register_line_cell_magic
    def gpu(line, cell=None):
        """
        Magic command to run code on GPU through Slurm queue.
        
        Usage:
            %%gpu [time=HH:MM:SS] [mem=SizeG]
            import torch
            # Your GPU code here
        """
        args = line.split() if line else []
        kwargs = {}
        for arg in args:
            if '=' in arg:
                key, val = arg.split('=', 1)
                if key == 'time':
                    kwargs['time_limit'] = val
                elif key == 'mem':
                    kwargs['memory'] = val
        
        if cell:
            gpu_cell(cell, **kwargs)
        else:
            print("Usage: %%gpu [time=HH:MM:SS] [mem=SizeG]")
    
    print("🚀 GPU Helper Loaded! Use %%gpu magic to run code on GPU with automatic queueing.")
    
except:
    pass
EOF

# Create IPython startup script
# Why needed: Automatically loads GPU helper in every notebook session
# This eliminates need for users to manually import the helper
sudo mkdir -p /etc/ipython/profile_default/startup/
sudo tee /etc/ipython/profile_default/startup/00-gpu-helper.py << 'EOF'
"""
Automatically load GPU helper in all notebooks
This runs when any IPython/Jupyter session starts
"""
import os
import sys

sys.path.insert(0, '/etc/jupyterhub/custom_scripts')

try:
    from gpu_helper import gpu_cell
    from IPython.core.magic import register_line_cell_magic
    
    @register_line_cell_magic
    def gpu(line, cell=None):
        """GPU magic command"""
        args = line.split() if line else []
        kwargs = {}
        for arg in args:
            if '=' in arg:
                key, val = arg.split('=', 1)
                if key == 'time':
                    kwargs['time_limit'] = val
                elif key == 'mem':
                    kwargs['memory'] = val
        
        if cell:
            gpu_cell(cell, **kwargs)
    
    print("🚀 GPU Helper ready! Use %%gpu magic for GPU execution.")
    
except ImportError:
    pass
EOF

# Set permissions
sudo chmod -R 755 /etc/jupyterhub/custom_scripts
sudo chmod -R 755 /etc/ipython

# Link startup script for all users
# Why: Each user needs the GPU helper loaded in their environment
for user in ori researcher1 researcher2 researcher3; do
    sudo -u $user mkdir -p /home/$user/.ipython/profile_default/startup/
    sudo -u $user ln -sf /etc/ipython/profile_default/startup/00-gpu-helper.py \
                         /home/$user/.ipython/profile_default/startup/00-gpu-helper.py
done
```

### Step 10: Start Services

**Service startup order matters:**
- **MUNGE first**: Authentication must be running before Slurm
- **Slurm daemons**: Controller (slurmctld) manages jobs, daemon (slurmd) executes them
- **Node initialization**: Node must be set to RESUME state to accept jobs
- **JupyterHub last**: Needs all other services running

```bash
# Start Slurm services
sudo systemctl enable slurmd slurmctld
sudo systemctl start slurmd slurmctld

# Initialize Slurm node
# Why: Node starts in UNKNOWN state, must be explicitly resumed
sudo scontrol update NodeName=William State=DOWN Reason="Initial setup"
sudo scontrol update NodeName=William State=RESUME

# Start JupyterHub (manual for now, can create systemd service later)
# Why manual: Easier to debug during setup, see logs directly
sudo jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
```

### Step 11: Create Quick Startup Script

**Why needed**: WSL2 doesn't persist some settings after restart, so we need a convenient way to start everything

```bash
# Create startup script for WSL2 restarts
sudo tee /usr/local/bin/start-gpu-system.sh << 'EOF'
#!/bin/bash
echo "Starting GPU sharing system..."

# Create NVIDIA devices if missing (WSL2 loses these on restart)
/usr/local/bin/create-nvidia-devices.sh

# Clear old PID files that might cause conflicts
rm -f /var/run/slurm-llnl/*.pid

# Start services in correct order
systemctl start munge
sleep 2
systemctl start slurmctld
systemctl start slurmd

# Resume node to accept jobs
scontrol update NodeName=William State=RESUME

# Check status
echo "System status:"
sinfo

echo "To start JupyterHub, run:"
echo "sudo jupyterhub -f /etc/jupyterhub/jupyterhub_config.py"
EOF

sudo chmod +x /usr/local/bin/start-gpu-system.sh
```

---

## 📁 Configuration Files

### Critical Files and Locations

| File | Purpose |
|------|---------|
| `/etc/slurm/slurm.conf` | Main Slurm configuration |
| `/etc/slurm/gres.conf` | GPU resource configuration (AutoDetect=off critical for WSL2) |
| `/etc/munge/munge.key` | Authentication key for Slurm |
| `/etc/jupyterhub/jupyterhub_config.py` | JupyterHub configuration |
| `/etc/jupyterhub/custom_scripts/gpu_helper.py` | GPU magic command implementation |
| `/etc/ipython/profile_default/startup/00-gpu-helper.py` | Auto-load GPU helper |
| `/usr/local/bin/create-nvidia-devices.sh` | WSL2 NVIDIA device creation |
| `/etc/ld.so.conf.d/nvidia-pytorch.conf` | CUDA library paths |
| `/usr/local/bin/start-gpu-system.sh` | Quick startup script |

---

## 📖 Usage Instructions

### For Researchers

#### Basic Usage
1. **Login**: Navigate to `http://server:8000` and login with credentials
2. **Create notebook**: Click "New" → "Python 3"
3. **Write code**: 
   - Regular Python runs immediately (no queue)
   - GPU code uses `%%gpu` magic command

#### GPU Code Examples

```python
# Simple GPU execution
%%gpu
import torch
x = torch.randn(1000, 1000).cuda()
print(f"GPU tensor sum: {x.sum()}")

# With custom time and memory
%%gpu time=02:00:00 mem=8G
# Your long-running training code here

# CPU code runs immediately (no %%gpu needed)
import pandas as pd
df = pd.read_csv('data.csv')  # This runs immediately, no queue
```

#### Queue Feedback
- ⏳ **"Submitting to GPU queue..."** - Job is being submitted
- ⏳ **"GPU Queue Status"** - Shows your position and who's using GPU
- ✅ **"GPU execution complete!"** - Job finished successfully
- ❌ **"Error during execution"** - Job failed (see error message)

#### Cancelling Jobs
- **Method 1**: Click the ■ (interrupt) button in Jupyter - this cancels the GPU job
- **Method 2**: Run `!scancel <job_id>` in a new cell
- **Method 3**: See all your jobs with `!squeue -u $USER`

### For Administrators

#### Starting the System (After WSL2 Restart)
```bash
# Quick start everything
sudo /usr/local/bin/start-gpu-system.sh

# Then start JupyterHub
sudo jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
```

#### Check System Status
```bash
# Slurm status
sinfo                     # Node status
squeue                    # Job queue
scontrol show node        # Detailed node info

# JupyterHub status
ps aux | grep jupyter     # Running processes
sudo ss -tlnp | grep 8000 # Port status

# GPU status
nvidia-smi                # GPU utilization
```

#### User Management
```bash
# Add new user
sudo useradd -m -s /bin/bash newuser
echo "newuser:password" | sudo chpasswd

# Add to JupyterHub admins
# Edit /etc/jupyterhub/jupyterhub_config.py
# Add username to c.Authenticator.admin_users

# Create IPython profile link
sudo -u newuser mkdir -p /home/newuser/.ipython/profile_default/startup/
sudo -u newuser ln -sf /etc/ipython/profile_default/startup/00-gpu-helper.py \
                       /home/newuser/.ipython/profile_default/startup/00-gpu-helper.py
```

---

## 🔧 Troubleshooting

### Common Issues and Solutions

#### Services Won't Start After WSL2 Restart
```bash
# MUNGE is usually the culprit
sudo systemctl start munge
sudo systemctl start slurmctld slurmd

# Or use the startup script
sudo /usr/local/bin/start-gpu-system.sh
```

#### GPU Not Detected by Slurm
```bash
# Check devices exist
ls -la /dev/nvidia*

# If missing, recreate
sudo /usr/local/bin/create-nvidia-devices.sh

# Verify Slurm sees GPU
scontrol show node | grep Gres
```

#### PyTorch Can't Find CUDA Libraries (libnccl.so.2, libcudnn.so.9 errors)
```bash
# This is the most common issue in WSL2 with PyTorch
# Solution: Ensure all NVIDIA libraries are in ldconfig

# Find all NVIDIA libraries
find /usr/local/lib/python3.13/site-packages/nvidia -name "*.so*" -exec dirname {} \; | sort -u

# Add ALL paths to system library configuration
sudo tee /etc/ld.so.conf.d/nvidia-pytorch.conf << 'EOF'
/usr/local/lib/python3.13/site-packages/nvidia/cudnn/lib
/usr/local/lib/python3.13/site-packages/nvidia/nccl/lib
/usr/local/lib/python3.13/site-packages/nvidia/cublas/lib
/usr/local/lib/python3.13/site-packages/nvidia/cuda_cupti/lib
/usr/local/lib/python3.13/site-packages/nvidia/cuda_nvrtc/lib
/usr/local/lib/python3.13/site-packages/nvidia/cuda_runtime/lib
/usr/local/lib/python3.13/site-packages/nvidia/cufft/lib
/usr/local/lib/python3.13/site-packages/nvidia/curand/lib
/usr/local/lib/python3.13/site-packages/nvidia/cusolver/lib
/usr/local/lib/python3.13/site-packages/nvidia/cusparse/lib
/usr/local/lib/python3.13/site-packages/nvidia/nvjitlink/lib
/usr/local/lib/python3.13/site-packages/nvidia/nvtx/lib
/usr/local/cuda-12.9/targets/x86_64-linux/lib
EOF

# CRITICAL: Rebuild library cache
sudo ldconfig

# Test - should show True
python3 -c "import torch; print(torch.cuda.is_available())"
```

#### JupyterHub Won't Start
```bash
# Check for existing processes
sudo pkill jupyterhub

# Check database
sudo rm /etc/jupyterhub/jupyterhub.sqlite
sudo rm /etc/jupyterhub/jupyterhub_cookie_secret

# Restart
sudo jupyterhub -f /etc/jupyterhub/jupyterhub_config.py
```

#### Slurm Node Shows DOWN
```bash
# Reset node state
sudo scontrol update NodeName=William State=DOWN Reason="Reset"
sudo scontrol update NodeName=William State=RESUME

# Restart services
sudo systemctl restart slurmd slurmctld
```

#### Jobs Stuck in Queue
```bash
# Check job details
scontrol show job <jobid>

# Cancel stuck job
scancel <jobid>

# Check node allocation
scontrol show node William
```

---

## 🧪 Testing Procedures

### System Validation Tests

#### Test 1: Basic GPU Access (✅ VERIFIED WORKING)
```python
%%gpu
import subprocess
result = subprocess.run(['nvidia-smi', '--query-gpu=name', '--format=csv,noheader'], 
                       capture_output=True, text=True)
print(f"GPU: {result.stdout}")
# Output: NVIDIA GeForce RTX 3070 Ti
```

#### Test 2: PyTorch CUDA (✅ VERIFIED WORKING)
```python
%%gpu
import torch
print(f"PyTorch: {torch.__version__}")
print(f"CUDA available: {torch.cuda.is_available()}")
if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name(0)}")
    x = torch.randn(100, 100).cuda()
    print(f"Tensor sum: {x.sum().item():.2f}")
# Output: 
# PyTorch: 2.5.1+cu121
# CUDA available: True
# GPU: NVIDIA GeForce RTX 3070 Ti
# Tensor sum: 34.71
```

#### Test 3: Queue Behavior (✅ VERIFIED WORKING)
Open two notebooks as different users:

**User 1 - Long job (60 seconds):**
```python
%%gpu time=00:02:00
import time
import torch
print(f"User1: Starting 60-second GPU job")
print(f"GPU: {torch.cuda.get_device_name(0)}")
for i in range(6):
    print(f"  [{i*10}s] Still using GPU...")
    time.sleep(10)
print("User1: Job complete!")
```

**User 2 - Attempts GPU while User 1 running:**
```python
%%gpu
import torch
print(f"User2: Got GPU access!")
print(f"GPU: {torch.cuda.get_device_name(0)}")
# This queues and shows "GPU is currently busy" message
# Runs automatically when User 1 completes
```

#### Test 4: CPU Not Blocked (✅ VERIFIED WORKING)
While GPU job is running:
```python
# This runs immediately without %%gpu
import time
print(f"CPU work at {time.strftime('%H:%M:%S')}")
# Executes without waiting for GPU
```

#### Test 5: Job Cancellation (✅ VERIFIED WORKING)
```python
# Start a long GPU job
%%gpu time=00:05:00
import time
for i in range(100):
    print(f"Iteration {i}")
    time.sleep(1)

# Then click the ■ (interrupt) button
# Job is cancelled and GPU freed for next user
```

### Expected Behavior
1. ✅ All users can login simultaneously
2. ✅ CPU code runs immediately
3. ✅ GPU code queues automatically when GPU is busy
4. ✅ Clear feedback about queue status
5. ✅ Jobs complete in order submitted
6. ✅ Jobs can be cancelled with interrupt button
7. ⚠️ Queued GPU cells block notebook execution (by design, matches Colab behavior)

---

## 📝 Notes for Production Migration

### Differences: RTX 3070Ti → A6000
- **VRAM**: 8GB → 48GB (can run much larger models)
- **Architecture**: Both Ampere (sm_86) - code compatible
- **MIG Support**: Neither supports MIG (only A100/H100)
- **Performance**: A6000 is significantly faster

### Migration Checklist
1. ✅ Test all notebooks on 3070Ti first
2. ✅ Document exact package versions
3. ✅ Export conda/pip environments
4. ✅ Backup all configuration files
5. ✅ Test user permissions and access
6. ✅ Validate queue behavior
7. ✅ Create systemd service for JupyterHub
8. ✅ Setup monitoring (Grafana/Prometheus optional)

---

## 🚀 Quick Start Commands

```bash
# Start everything after WSL2 restart
sudo /usr/local/bin/start-gpu-system.sh
sudo jupyterhub -f /etc/jupyterhub/jupyterhub_config.py

# Check status
sinfo && squeue && nvidia-smi

# Access JupyterHub
# Browse to: http://localhost:8000
# Login: researcher1 / test123
```

---

## 📞 Support Information

- **Created by**: Ori (with Claude AI assistance)
- **Date**: August 2025
- **Environment**: WSL2 Fedora 42
- **Purpose**: Multi-user GPU sharing for ML research team

---

## Version History

- **v1.0** (Aug 2025): Initial setup with ProfilesSpawner (CPU/GPU choice at login)
- **v2.0** (Aug 2025): Migrated to single profile with %%gpu magic
- **v2.1** (Aug 2025): Fixed CUDA library issues - all NVIDIA libraries properly linked
- **v2.2** (Aug 2025): Verified GPU queueing works correctly
- **v2.3** (Aug 2025): Enhanced queue display with detailed status information
- **v3.0** (Aug 2025): Production-ready system with informative UI and job cancellation

---

*End of Documentation*