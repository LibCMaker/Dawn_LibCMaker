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

// The code is based on the codes from:
// https://github.com/google/dawn/blob/main/docs/quickstart-cmake.md#create-test-code

#include <webgpu/webgpu_cpp.h>
#include <webgpu/webgpu_cpp_print.h>

#include "gtest/gtest.h"

TEST(Examle, dawn)
{
  static constexpr auto kTimedWaitAny = wgpu::InstanceFeatureName::TimedWaitAny;
  wgpu::InstanceDescriptor instanceDescriptor{
    .requiredFeatureCount = 1,
    .requiredFeatures = &kTimedWaitAny
  };

  wgpu::Instance instance = wgpu::CreateInstance(&instanceDescriptor);
  if (instance == nullptr) {
    ASSERT_TRUE(false);
  }

  // Synchronously request the adapter.
  wgpu::RequestAdapterOptions options = {};
  wgpu::Adapter adapter;

  auto callback = [](wgpu::RequestAdapterStatus status, wgpu::Adapter adapter, wgpu::StringView message, void *userdata) {
    if (status != wgpu::RequestAdapterStatus::Success) {
      ASSERT_TRUE(false);
      return;
    }
    *static_cast<wgpu::Adapter *>(userdata) = adapter;
  };


  auto callbackMode = wgpu::CallbackMode::WaitAnyOnly;
  void *userdata = &adapter;
  instance.WaitAny(instance.RequestAdapter(&options, callbackMode, callback, userdata), UINT64_MAX);
  if (adapter == nullptr) {
    ASSERT_TRUE(false);
  }

  wgpu::DawnAdapterPropertiesPowerPreference power_props{};

  wgpu::AdapterInfo info{};
  info.nextInChain = &power_props;

  adapter.GetInfo(&info);

  ASSERT_TRUE(info.vendor.length > 0);
  ASSERT_TRUE(info.architecture.length > 0);
  ASSERT_TRUE(info.device.length > 0);
  ASSERT_TRUE(info.description.length > 0);
}
