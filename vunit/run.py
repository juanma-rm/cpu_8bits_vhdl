######################################################
# Python libraries
######################################################

from pathlib import Path
from vunit import VUnit
import sys

######################################################
# Paths, sources and dependencies
######################################################

# Needed because when you call this script with python, maybe you are not in the same directory where the run.py is. To avoid this issue, we get the path of the run.py.
ROOT = Path(__file__).parent
SRC_PATH = ROOT / "../src"
# PRJ_PATH = ROOT / "../projects/myProject"

# Create VUnit instance by parsing command line arguments
VU = VUnit.from_argv()

# Add Verification Components (AXIS, AXI4-Lite....) to the VUnit library
# VU.add_verification_components()

# Create library
slib = VU.add_library("src_lib")

# Add sources to the library
slib.add_source_files(
    [
        # Dependencies
        SRC_PATH / "utils_pkg.vhd",
        SRC_PATH / "ALU.vhd",
        # Testbench
        ROOT / "vunit_tb.vhd",
    ])

# Add external libraries


######################################################
# Config Testbench: ALU
######################################################

tb_dut = slib.test_bench("vunit_tb")

# Config1
config_1_dic = dict(
    num_frames_g        = 4,
)

# Config2
config_2_dic = dict(config_1_dic)
config_2_dic['num_frames_g'] = 8

# Iterate all configs and add to tb_dut
config_list = [config_1_dic, config_2_dic]
for pos in range(len(config_list)):
    config_dic = config_list[pos]
    tb_dut.add_config(
        name = "config" + str(pos),
        generics = config_dic
    )

######################################################
# ModelSim simulation options
######################################################

if len(sys.argv) > 1:
    if sys.argv[1] == '--gui':
        VU.set_sim_option(name="modelsim.init_files.after_load",
                        value=["runall_addwave.do"])

        VU.set_sim_option("modelsim.vsim_flags", [
                        "-voptargs=\"+acc", "-L work -L pmi_work -L ovi_lifcl"])

######################################################
# Run vunit function
######################################################

VU.main()