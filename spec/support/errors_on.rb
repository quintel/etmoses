# From rspec-collection_matchers

# (The MIT License)
#
# Copyright (c) 2013 Hugo Barauna
# Copyright (c) 2012 David Chelimsky, Myron Marston
# Copyright (c) 2006 David Chelimsky, The RSpec Development Team
# Copyright (c) 2005 Steven Baker
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module ::ActiveModel::Validations
  # Extension to enhance `to have` on AR Model instances.  Calls
  # model.valid? in order to prepare the object's errors object. Accepts
  # a :context option to specify the validation context.
  #
  # You can also use this to specify the content of the error messages.
  #
  # @example
  #
  #     expect(model).to have(:no).errors_on(:attribute)
  #     expect(model).to have(1).error_on(:attribute)
  #     expect(model).to have(n).errors_on(:attribute)
  #     expect(model).to have(n).errors_on(:attribute, :context => :create)
  #
  #     expect(model.errors_on(:attribute)).to include("can't be blank")
  def errors_on(attribute, options = {})
    valid_args = [options[:context]].compact
    self.valid?(*valid_args)

    [self.errors[attribute]].flatten.compact
  end

  alias :error_on :errors_on
end
