//----------------------------------------------------------------------------//
//|
//|             MachOKit - A Lightweight Mach-O Parsing Library
//|             MKBackedNode+Pointer.m
//|
//|             D.V.
//|             Copyright (c) 2014-2015 D.V. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

#import "MKBackedNode+Pointer.h"

//----------------------------------------------------------------------------//
@implementation MKBackedNode (Pointer)

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeOccupyingVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
    mk_vm_range_t range = mk_vm_range_make(self.nodeVMAddress, self.nodeSize);
    if (mk_vm_range_contains_address(range, 0, address) == MK_ESUCCESS && (targetClass == nil || [self isKindOfClass:targetClass]))
        return [MKOptional optionalWithValue:self];
    else
        return [MKOptional optional];
}


//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeAtVMAddress:(mk_vm_address_t)address targetClass:(Class)targetClass
{
    MKOptional<MKBackedNode*> *child = [self childNodeOccupyingVMAddress:address targetClass:nil];
    
    // Some nodes may 'create' the child node upon request.
    if (child.value && child.value != self)
        child = [child.value childNodeAtVMAddress:address targetClass:targetClass];
    
    if (child.value && (targetClass == nil || [child.value isKindOfClass:targetClass])) {
        if (child.value.nodeVMAddress == address)
            // Found a child node at address
            return child;
        else
            // Did not find a child node at address
            return [MKOptional optional];
    } else
        // There was an error finding (or creating) the child node at address.
        return child;
}

//|++++++++++++++++++++++++++++++++++++|//
- (MKOptional*)childNodeAtVMAddress:(mk_vm_address_t)address
{
    return [self childNodeAtVMAddress:address targetClass:nil];
}

@end