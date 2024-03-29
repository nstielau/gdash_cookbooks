#
# Cookbook Name:: graphite
# Recipe:: default
#
# Copyright 2011, Heavy Water Software Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "graphite::dependencies"
include_recipe "graphite::whisper"
include_recipe "graphite::carbon"
include_recipe "graphite::web"
include_recipe "graphite::gdash"
include_recipe "graphite::dummy_data"
include_recipe "graphite::chef"
