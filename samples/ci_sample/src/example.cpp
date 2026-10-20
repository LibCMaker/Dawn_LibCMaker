/*****************************************************************************
 * Project:  LibCMaker
 * Purpose:  A CMake build scripts for build libraries with CMake
 * Author:   NikitaFeodonit, nfeodonit@yandex.com
 *****************************************************************************
 *   Copyright (c) 2017-2026 NikitaFeodonit
 *
 *    This file is part of the LibCMaker project.
 *
 *    This program is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published
 *    by the Free Software Foundation, either version 3 of the License,
 *    or (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *    See the GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with this program. If not, see <http://www.gnu.org/licenses/>.
 ****************************************************************************/

// The code is from:
// https://github.com/google/dawn/blob/main/docs/quickstart-cmake.md#create-test-code

#include <webgpu/webgpu_cpp.h>
#include <webgpu/webgpu_cpp_print.h>

#include <cstdlib>
#include <iostream>

int main(int argc, char *argv[]) {
  static constexpr auto kTimedWaitAny = wgpu::InstanceFeatureName::TimedWaitAny;
  wgpu::InstanceDescriptor instanceDescriptor{
    .requiredFeatureCount = 1,
    .requiredFeatures = &kTimedWaitAny
  };

  wgpu::Instance instance = wgpu::CreateInstance(&instanceDescriptor);
  if (instance == nullptr) {
    std::cerr << "Instance creation failed!\n";
    return EXIT_FAILURE;
  }
  // Synchronously request the adapter.
  wgpu::RequestAdapterOptions options = {};
  wgpu::Adapter adapter;

  auto callback = [](wgpu::RequestAdapterStatus status, wgpu::Adapter adapter, wgpu::StringView message, void *userdata) {
    if (status != wgpu::RequestAdapterStatus::Success) {
      std::cerr << "Failed to get an adapter:" << message;
      return;
    }
    *static_cast<wgpu::Adapter *>(userdata) = adapter;
  };


  auto callbackMode = wgpu::CallbackMode::WaitAnyOnly;
  void *userdata = &adapter;
  instance.WaitAny(instance.RequestAdapter(&options, callbackMode, callback, userdata), UINT64_MAX);
  if (adapter == nullptr) {
    std::cerr << "RequestAdapter failed!\n";
    return EXIT_FAILURE;
  }

  wgpu::DawnAdapterPropertiesPowerPreference power_props{};

  wgpu::AdapterInfo info{};
  info.nextInChain = &power_props;

  adapter.GetInfo(&info);
  std::cout << "VendorID: " << std::hex << info.vendorID << std::dec << "\n";
  std::cout << "Vendor: " << info.vendor << "\n";
  std::cout << "Architecture: " << info.architecture << "\n";
  std::cout << "DeviceID: " << std::hex << info.deviceID << std::dec << "\n";
  std::cout << "Name: " << info.device << "\n";
  std::cout << "Driver description: " << info.description << "\n";
  return EXIT_SUCCESS;
}
