// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
#deprecated("Use `unsafe_pop_front` instead")
#coverage.skip
pub fn[A] pop_front_exn(self : T[A]) -> Unit {
  self.unsafe_pop_front()
}

///|
#deprecated("Use `unsafe_pop_back` instead")
#coverage.skip
pub fn[A] pop_back_exn(self : T[A]) -> Unit {
  self.unsafe_pop_back()
}

///|
#deprecated("Use `@deque.retain_map` instead")
pub fn[A] filter_map_inplace(self : T[A], f : (A) -> A?) -> Unit {
  self.retain_map(f)
}

///|
